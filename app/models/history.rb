class History < ActiveRecord::Base
	belongs_to :stock
	validates_uniqueness_of :date, :scope => :stock_id
	validates :date, presence: true

	before_save :dates_to_ymd_only

	def self.insert_or_update(history_hashes)
		begin
	    History.transaction do
	    	history_hashes.each_pair do |ticker, values_array|
	    		save_price_points(ticker, values_array)
	    	end
	    end
	  rescue => e
	    Rails.logger.info("There was an exception: #{e}")
	  end
	end

	private

	def self.save_price_points(ticker, values_array)
		stock = Stock.where(ticker: ticker).first
		values_array.each do |values_hash|
			history = stock.histories.where(date: values_hash[:date]).first
			if history.nil?
				stock.histories.create(values_hash)
			end
		end			
	end	

	def dates_to_ymd_only
		if self.date
			year_month_day = self.date.strftime "%Y,%m,%d"
			ymd = year_month_day.split(',').map {|x| x.to_i}
			self.date = DateTime.new(ymd[0],ymd[1],ymd[2])
		end
	end
end
