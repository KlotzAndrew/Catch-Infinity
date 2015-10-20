json.array!(@backtests) do |backtest|
  json.extract! backtest, :id
  json.url backtest_url(backtest, format: :json)
end
