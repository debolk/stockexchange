class Commodity < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true
  validates :floor_price, presence: true, numericality: true
  validates :ceiling_price, presence: true, numericality: true
  validates :buyback_price, presence: true, numericality: true
  validates :bar_price, presence: true, numericality: true
  validates :markup, presence: true, numericality: true

  has_many :buy_orders
  has_many :sell_orders
  has_many :transactions

  def rate
    transactions.order('created_at DESC').first.buy_rate
  end
end
