class SellOrder < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :commodity

  validates :amount, presence: true, numericality: true
  validates :price, presence: true, numericality: true
  validates :commodity, presence: true
end
