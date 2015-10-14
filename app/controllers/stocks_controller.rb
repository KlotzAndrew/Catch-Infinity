class StocksController < ApplicationController
  before_action :set_stock, only: [:show]

  def index
    @stocks = Stock.all_prices
  end

  def show
  end

  def current_quotes
    Stock.current_price
    respond_to do |format|
      format.html {redirect_to root_path}
    end
  end

  def past_prices
    Stock.past_prices
    respond_to do |format|
      format.html {redirect_to root_path}
    end
  end

  private
    def set_stock
      @stock = Stock.find(params[:id])
    end

    def stock_params
      params[:stock]
    end
end
