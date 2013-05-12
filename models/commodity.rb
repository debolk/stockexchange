class Commodity < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true
  validates :floor_price, presence: true, numericality: true
  validates :ceiling_price, presence: true, numericality: true
  validates :buyback_price, presence: true, numericality: true

  has_many :buy_orders
  has_many :sell_orders
  has_many :transactions

  def bar_price
    result = ceiling_price
    if sell_orders.where('state = ?', 'open').any?
      result = [result, sell_orders.where('state = ?', 'open').minimum('price')].min
    end
    if buy_orders.where('state = ?', 'open').any?
      result = [result, buy_orders.where('state = ?', 'open').maximum('price')].max
    end
    result
  end
end
