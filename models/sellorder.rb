class SellOrder < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :commodity

  validates :price, presence: true, numericality: true
  validates :commodity, presence: true

  def self.remove_all!
    SellOrder.where(state: :open).destroy_all
  end
end
