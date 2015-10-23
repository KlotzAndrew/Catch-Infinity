module BacktestsHelper
	def month_difference(date1,date2)
	  month = (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month)
	  return "#{month} months"
	end
end
