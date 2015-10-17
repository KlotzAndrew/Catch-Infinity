class History < ActiveRecord::Base
	belongs_to :stock

	def self.insert_or_update(history_hashes)
		begin
	    History.transaction do
	    	history_hashes.each_pair do |ticker, values|
	    		save_price_points(ticker, values)
	    	end
	    end
	  rescue => e
	    Rails.logger.info("There was an exception: #{e}")
	  end
	end

	def self.save_price_points(ticker, values)
		stock = Stock.where(ticker: ticker).first
		values.each_pair do |date, data|
			history = stock.histories.where(date: date).first
			if history.nil?
				History.create(
					price_day_close: data[:price_day_close],
					date: date,
					stock_id: stock.id)
			end
		end			
	end	
end
