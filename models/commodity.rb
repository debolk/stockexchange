class Commodity < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true
  validates :floor_price, presence: true, numericality: true
  validates :ceiling_price, presence: true, numericality: true
  validates :buyback_price, presence: true, numericality: true
  validates :bar_price, presence: true, numericality: true
  validates :markup, presence: true, numericality: true
  validates :orderbook_size, presence: true, numericality: true

  has_many :buy_orders
  has_many :sell_orders
  has_many :transactions

  def rate
    t = transactions.order('created_at DESC').first
    if t == nil
      return floor_price
    end
    t.buy_rate
  end

  def min_price
    if orderbook_size < 1
      return ceiling_price
    end
    min = buy_orders.where('state = ?', 'open').order('price DESC').offset(orderbook_size - 1)
    if !min.any?
      return 0
    end
    return min.first.price + 10
  end

  def self.disable_supply!
    Commodity.update_all supply_rate: 0
  end
end
