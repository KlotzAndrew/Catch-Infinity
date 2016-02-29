# frozen_string_literal: true
module Fetcher
  # Retrieves historical daily stock pries from Yahoo Finance
  class Histories
    attr_reader :tickers, :query_start, :query_end

    READ_TIMEOUT    = 10
    YAHOO_API_START = 'https://query.yahooapis.com/v1/public/yql?q='.freeze
    YAHOO_API_QUERY = 'select * from yahoo.finance.historicaldata where symbol'\
                      ' = "ticker" and startDate = "@query_start" and endDate'\
                      ' = "@query_end"'.freeze
    YAHOO_API_END   = '&format=json&diagnostics=true&env=store%3A%2F%2F'\
                      'datatables.org%2Falltableswithkeys&callback='.freeze

    DEFAULT_QUERY_START = 3.months.ago
    DEFAULT_QUERY_END   = Time.now

    def initialize(ticker_array, options = {})
      @tickers = ticker_array
      @query_end = options[:query_start] || DEFAULT_QUERY_END
      @query_start = options[:query_end] || DEFAULT_QUERY_START
      @query_end = @query_end.strftime('%Y-%m-%d')
      @query_start = @query_start.strftime('%Y-%m-%d')
    end

    def fetch
      send_tickers_to_api
    end

    private

    def send_tickers_to_api
      history_hash = Hash.new(0)
      @tickers.each do |ticker|
        add_stock_to_hash(ticker, history_hash)
      end
      history_hash
    end

    def add_stock_to_hash(ticker, history_hash)
      url = yahoo_history_url(ticker)
      message = open(url, read_timeout: READ_TIMEOUT).read
      history_hash.merge!(parse_stock_timeseries(message))
    end

    def yahoo_history_url(ticker)
      url = YAHOO_API_START
      url += build_yql_query_body(ticker)
      url += YAHOO_API_END

      url
    end

    def build_yql_query_body(ticker)
      body = YAHOO_API_QUERY.gsub('ticker', ticker)
                            .gsub('@query_start', @query_start)
                            .gsub('@query_end', @query_end)
      encoded_body = URI.encode(body).gsub('=', '%3D')

      encoded_body
    end

    def parse_stock_timeseries(message)
      json = JSON.parse(message)
      data = find_data_if_response(json)
      stock_hash = hash_stock_timeseries(data)
      stock_series = { data.first['Symbol'] => stock_hash }
      stock_series
    end

    def find_data_if_response(json)
      if json['query']['http-status-code'] != '404'
        json['query']['results']['quote']
      end
    end

    def hash_stock_timeseries(data)
      stock_array = []
      data.each do |days_info|
        date = parse_year_month_day(days_info)
        stock_array << {
          date: date,
          price_day_close: BigDecimal.new((days_info['High']).to_s)
        }
      end
      stock_array
    end

    def parse_year_month_day(days_info)
      date_ymd = days_info['Date'].split('-').map(&:to_i)
      DateTime.new(date_ymd[0], date_ymd[1], date_ymd[2])
    end
  end
end
