class BacktestsController < ApplicationController
  before_action :set_backtest, only: [:show, :edit, :update, :destroy]

  def index
    @backtests = Backtest.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @stocks = Stock.all
    @backtest = Backtest.new
  end

  def create
    options = {
        query_start: DateTime.new(
          backtest_params["query_start(1i)"].to_i,
          backtest_params["query_start(2i)"].to_i,
          backtest_params["query_start(3i)"].to_i),
        query_end: DateTime.new(
          backtest_params["query_end(1i)"].to_i,
          backtest_params["query_end(2i)"].to_i,
          backtest_params["query_end(3i)"].to_i),
        value_start: backtest_params[:value_start].to_i,
        dollar_cost_average: false,
        sell_signal: "p>20>50",
        buy_signal: "p<20<50",
        stocks:  parse_backtest_params(backtest_params["stocks"])
      }

    calculator = Calculator::Backtests.new(options)
    answers = calculator.calculate

    backtest_hash = {
      query_start: options[:query_start],
      query_end: options[:query_end],
      value_start: options[:value_start],
      dollar_cost_average: options[:dollar_cost_average],
      sell_signal: options[:sell_signal],
      buy_signal: options[:buy_signal],
      value_end: answers[:value_end]
    }
    @backtest = Backtest.insert_or_update(backtest_hash)
    answers[:trades_array].each do |trade_hash|
      trade_hash[:backtest_id] = @backtest.id
      Trade.insert_or_update(trade_hash)
    end

    respond_to do |format|
      if @backtest.save
        format.html { redirect_to backtests_path, notice: 'Backtest was successfully created.' }
        format.json { render :show, status: :created, location: @backtest }
      else
        format.html { render :new }
        format.json { render json: @backtest.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @backtest.destroy
    respond_to do |format|
      format.html { redirect_to backtests_url, notice: 'Backtest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def parse_backtest_params(stock_id_strings)
      stock_ids = stock_id_strings.select {|x| x unless x.empty?}
      return stock_ids.map {|x| Stock.find(x)}
    end

    def set_backtest
      @backtest = Backtest.find(params[:id])
    end

    def backtest_params
      params.require(:backtest).permit(:query_start, :query_end, :value_start, :dollar_cost_average, :sell_signal, :buy_signal, :stocks => [])
    end
end
