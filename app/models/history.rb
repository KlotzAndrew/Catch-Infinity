# === Schema Information
#
# Table name: histories
#
# id                   :integer    not null, primary key
# stock_id             :integer
# date                 :datetime
# price_day_close      :decimal
# created_at           :datetime   null: false
# updated_at           :datetime   null: false
class History < ActiveRecord::Base
  belongs_to :stock
  validates_uniqueness_of :date, scope: :stock_id
  validates :date, presence: true

  before_save :dates_to_ymd_only

  def self.insert_or_update(history_hashes)
    History.transaction do
      history_hashes.each_pair do |ticker, values_array|
        save_price_points(ticker, values_array)
      end
    end
  rescue => e
    Rails.logger.info("There was an exception: #{e}")
  end

  private

  class << self
    def save_price_points(ticker, values_array)
      stock = Stock.where(ticker: ticker).first
      values_array.each do |values_hash|
        history = stock.histories.where(date: values_hash[:date]).first
        stock.histories.create(values_hash) if history.nil?
      end
    end
  end

  def dates_to_ymd_only
    if date
      year_month_day = date.strftime '%Y,%m,%d'
      ymd = year_month_day.split(',').map(&:to_i)
      self.date = DateTime.new(ymd[0], ymd[1], ymd[2])
    end
  end
end
