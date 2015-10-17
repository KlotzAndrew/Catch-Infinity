require_relative '../../lib/catch_infinity/fetcher/stocks'
require_relative '../../lib/catch_infinity/builder/charts'

class StocksController < ApplicationController
  before_action :set_stock, only: [:show]

  def index
    @stock = Stock.new
    builder = Builder::Charts.new(Stock.all)
    @stocks = builder.format_for_google
  end

  def show
  end

  def update
    current_quotes
    redirect_to root_path
  end

  def mass_update
    update_quotes

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Updated all stock quotes!'}
      format.js
    end
  end

  def create
    stock = Stock.new(stock_params)
    update_quotes(Array(stock.ticker))
    stock = Stock.where(ticker: stock.ticker).first

    respond_to do |format|
      if !stock.nil?
        create_stock_histories([stock.ticker])
        format.html { redirect_to root_path, notice: 'Stock was successfully saved!'}
        format.js
      else
        format.html { redirect_to root_path, alert: 'Not able to save stock!' }
        format.js
      end
    end
  end

  private

  def update_quotes(tickers = Stock.all.pluck(:ticker))
    fetcher = Fetcher::Stocks.new(tickers)
    stock_hashes = fetcher.fetch
    Stock.insert_or_update(stock_hashes)
  end

  def create_stock_histories(ticker)
    fetcher = Fetcher::Histories.new(ticker)
    history_hashes = fetcher.fetch
    History.insert_or_update(history_hashes)
  end

    def set_stock
      @stock = Stock.find(params[:id])
    end

    def stock_params
      params.require(:stock).permit(:ticker)
    end
end
