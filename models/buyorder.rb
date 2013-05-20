class BuyOrder < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :commodity
  has_one :transaction
  
  validates :amount, presence: true, numericality: { :greater_than => 0, :less_than_or_equal_to => 10}
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
    if BuyOrder.count > 10
      BuyOrder.order('price asc').limit(1).destroy_all
    end
  end
end
