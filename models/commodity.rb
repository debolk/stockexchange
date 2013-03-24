class Commodity < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true
  validates :floor_price, presence: true, numericality: true
  validates :ceiling_price, presence: true, numericality: true
  validates :buyback_price, presence: true, numericality: true
end
