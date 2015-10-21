class BacktestsController < ApplicationController
  before_action :set_backtest, only: [:show, :edit, :update, :destroy]

  # GET /backtests
  # GET /backtests.json
  def index
    @backtests = Backtest.all
  end

  # GET /backtests/1
  # GET /backtests/1.json
  def show
  end

  # GET /backtests/new
  def new
    @backtest = Backtest.new
  end

  # GET /backtests/1/edit
  def edit
  end

  # POST /backtests
  # POST /backtests.json
  def create
    @backtest = Backtest.new(backtest_params)

    options = {
        query_start: DateTime.new(2015,10,19),
        query_end: (DateTime.new(2015,10,19) - 1.year),
        value_start: 10000,
        dollar_cost_average: false,
        sell_signal: "p>20>50",
        buy_signal: "p<20<50",
        stocks: Stock.all
      }

    calculator = Calculator::Backtests.new(options)
    answers = calculator.calculate
    options[:value_end] = answers[:value_end]

    backtest_hash = {
      value_start: options[:value_start],
      value_end: options[:value_end],
      dollar_cost_average: options[:dollar_cost_average],
      buy_signal: options[:buy_signal],
      sell_signal: options[:sell_signal],
      query_start: options[:query_start],
      query_end: options[:query_end]
    }
    backtest = Backtest.insert_or_update(backtest_hash)
    answers[:trades_array].each do |trade_hash|
      trade_hash[:backtest_id] = backtest.id
      Trade.insert_or_update(trade_hash)
    end

    respond_to do |format|
      if backtest.save
        format.html { redirect_to @backtest, notice: 'Backtest was successfully created.' }
        format.json { render :show, status: :created, location: @backtest }
      else
        format.html { render :new }
        format.json { render json: @backtest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /backtests/1
  # PATCH/PUT /backtests/1.json
  def update
    respond_to do |format|
      if @backtest.update(backtest_params)
        format.html { redirect_to @backtest, notice: 'Backtest was successfully updated.' }
        format.json { render :show, status: :ok, location: @backtest }
      else
        format.html { render :edit }
        format.json { render json: @backtest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /backtests/1
  # DELETE /backtests/1.json
  def destroy
    @backtest.destroy
    respond_to do |format|
      format.html { redirect_to backtests_url, notice: 'Backtest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_backtest
      @backtest = Backtest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def backtest_params
      params[:backtest]
    end
end
