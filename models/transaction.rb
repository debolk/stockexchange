class Transaction < ActiveRecord::Base
  belongs_to :commodity
  belongs_to :buy_order
  
  validates :amount, presence: true, numericality: true
  validates :buy_price, presence: true, numericality: true
  validates :sell_price, presence: true, numericality: true
  validates :commodity, presence: true

  def commodity_name
    commodity.name
  end

  def buy_rate
    buy_price / amount
  end

  def sell_rate
    sell_price / amount
  end
end
