class BuyOrder < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :commodity
  has_one :transaction
  
  validates :amount, presence: true, numericality: { :greater_than => 0, :less_than_or_equal_to => 10}
  validates :price, presence: true, numericality: true
  validates :commodity, presence: true
  validates_uniqueness_of :commodity_id, :scope => [:phone, :state, :deleted_at], :unless => Proc.new {|bo| bo.deleted?}, :if => Proc.new {|bo| bo.state == 'open'}

  def commodity_name
    commodity.name
  end

  def total_value
    price*amount
  end

  def match!(sell_orders)
    update_attribute :state, :matched
    sell_orders.update_all state: :matched
    Transaction.create do |t|
      t.commodity = buy_order.commodity
      t.amount = buy_order.amount
      t.buy_price = buy_order.total_value
      t.sell_price = sell_orders.sum(:price)
      t.save
    end
  end

  def self.open_orders
    order('price DESC').where('state = ?', 'open')
  end
end
