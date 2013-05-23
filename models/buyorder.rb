class BuyOrder < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :commodity
  has_one :transaction
  
  validates :amount, presence: true, numericality: true
  validates :price, presence: true, numericality: true
  validates :commodity, presence: true
  validates_uniqueness_of :commodity_id, :scope => [:phone, :state, :deleted_at], :unless => Proc.new {|bo| bo.deleted?}, :if => Proc.new {|bo| bo.state == 'open'}

  after_create :remove_lowest_order

  def commodity_name
    commodity.name
  end

  def total_value
    price*amount
  end

  private

  def remove_lowest_order
    Commodity.all.each do |commodity|
      to_be_destroyed = commodity.buy_orders.count - 10
      if to_be_destroyed > 0
        commodity.buy_orders.order('price asc').limit(to_be_destroyed).destroy_all
      end
    end
  end
end
