require_relative '../../lib/catch_infinity/fetcher/histories'

class HistoriesController < ApplicationController

	def mass_update
		update_histories
		respond_to do |format|
      format.html { redirect_to root_path, notice: 'Updated all stock histories!'}
      format.js
    end
	end

	private

  def update_histories(tickers = Stock.all.pluck(:ticker))
    fetcher = Fetcher::Histories.new(tickers)
    history_hashes = fetcher.fetch
    History.insert_or_update(history_hashes)
  end
end
