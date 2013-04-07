class BuyOrder < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :commodity
  
  validates :amount, presence: true, numericality: true
  validates :price, presence: true, numericality: true
  validates :commodity, presence: true

  validates_uniqueness_of :commodity_id, :scope => :phone

  def commodity_name
    commodity.name
  end

  def total_value
    price*amount
  end
end
