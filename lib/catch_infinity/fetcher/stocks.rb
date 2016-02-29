# frozen_string_literal: true
module Fetcher
  # Retrieves current stock pries from Yahoo Finance
  class Stocks
    attr_reader :tickers

    BATCHLIMIT_QUOTES = 400
    READ_TIMEOUT = 10

    YAHOO_API_START   = 'https://query.yahooapis.com/v1/public/yql?q='.freeze
    YAHOO_API_QUERY   = 'SELECT * FROM yahoo.finance.quotes WHERE symbol IN'\
                        ' (yahoo_tickers)'.freeze
    YAHOO_API_END = '&format=json&diagnostics=true&env=store%3A%2F%2F'\
                        'datatables.org%2Falltableswithkeys&callback='.freeze

    def initialize(ticker_array)
      @tickers = ticker_array
    end

    def fetch
      send_tickers_to_api
    end

    private

    def send_tickers_to_api
      # limit of BATCHLIMIT_QUOTES per api call
      yahoo_tickers = tickers_yahoo_format
      return nil unless yahoo_tickers.length > 0
      request_and_collect_api(yahoo_tickers)
    end

    def request_and_collect_api(yahoo_tickers)
      url = yahoo_quote_url(yahoo_tickers)
      message = open(url, read_timeout: READ_TIMEOUT).read
      parse_quote_data(message)
    end

    def tickers_yahoo_format
      valid_stocks = @tickers.select { |x| x if x.length > 0 }
      valid_stocks.map { |x| "'" + x + "'" }.join(', ')
    end

    def yahoo_quote_url(yahoo_tickers)
      url = YAHOO_API_START
      url += build_yql_query_body(yahoo_tickers)
      url += YAHOO_API_END

      url
    end

    def build_yql_query_body(yahoo_tickers)
      url = YAHOO_API_QUERY.gsub('yahoo_tickers', yahoo_tickers)
      url = URI.encode(url)

      url
    end

    def parse_quote_data(message)
      response_data = format_from_json(message)

      stocks_array = []
      if response_value_is_hash?(response_data)
        hash = combine_price_hashes(response_data)
        stocks_array << hash unless hash.nil?
      else
        response_data.each do |stock_hash|
          hash = combine_price_hashes(stock_hash)
          stocks_array << hash unless hash.nil?
        end
      end
      stocks_array
    end

    def format_from_json(message)
      response_data = JSON.parse(message)
      response_data['query']['results']['quote']
    end

    def response_value_is_hash?(response_data)
      return true if response_data.class == Hash
    end

    def combine_price_hashes(stock_hash)
      if stock_hash['Name'].nil?
        nil
      else
        {
          ticker: stock_hash['symbol'],
          name: stock_hash['Name'],
          last_price: BigDecimal.new(stock_hash['LastTradePriceOnly']),
          last_trade: parse_last_trade_time(stock_hash),
          stock_exchange: stock_hash['StockExchange']
        }
      end
    end

    def parse_last_trade_time(stock_hash)
      mdy = parse_month_day_year(stock_hash)
      hrs_mins = parse_hrs_mins(stock_hash)
      DateTime.new(mdy[2], mdy[0], mdy[1], hrs_mins[0], hrs_mins[1])
    end

    def parse_month_day_year(stock_hash)
      stock_hash['LastTradeDate'].split('/').map(&:to_i)
    end

    # TODO: hrs_mins is a value object [hours, minutes]
    def parse_hrs_mins(stock_hash)
      clock12hr = stock_hash['LastTradeWithTime'].split.first
      is_pm = time_pm?(clock12hr)
      hrs_mins = clock12hr[0..clock12hr.length - 3].split(':').map(&:to_i)
      hrs_mins[0] += 12 if is_pm && hrs_mins[0] < 12
      hrs_mins
    end

    def time_pm?(clock12hr)
      pm_value = clock12hr[clock12hr.length - 2..clock12hr.length - 1]
      return true if pm_value == 'pm'
    end
  end
end
