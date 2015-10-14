class StocksController < ApplicationController
  before_action :set_stock, only: [:show]

  def index
    @stock = Stock.new
    @stocks = Stock.all_prices
  end

  def show
  end

  def create
    stock = Stock.new(stock_params)
    Stock.current_price([stock])
    # Stock.current_price
    # respond_to do |format|
    #   if @ticket.save
    #     format.html { redirect_to tournament_path(@ticket.tournament.id, :active_ticket => @ticket)}
    #     format.js
    #   else
    #     format.html { render :new }
    #     format.js
    #   end
    # end
    redirect_to root_path
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
      params.require(:stock).permit(:ticker)
    end
end
