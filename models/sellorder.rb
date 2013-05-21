class SellOrder < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :commodity

  validates :price, presence: true, numericality: true
  validates :commodity, presence: true

  def self.remove_all!
    SellOrder.where(state: :open).destroy_all
  end

  def self.find_qualifying_orders(buy_order)
    order('price DESC').where('commodity_id', buy_order.commodity.id).where('state = ?', 'open').where('price <= ?', buy_order.price).limit(buy_order.amount)
  end
end
