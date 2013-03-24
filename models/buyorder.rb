class BuyOrder < ActiveRecord::Base

  validates :amount, presence: true, numericality: true
  validates :price, presence: true, numericality: true
end
