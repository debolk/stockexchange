class SellOrder < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :commodity

  validates :price, presence: true, numericality: true
  validates :commodity, presence: true

  after_create :remove_lowest_order

  private

  def remove_lowest_order
    Commodity.all.each do |commodity|
      to_be_destroyed = commodity.buy_orders.count - 10
      if to_be_destroyed > 0
        commodity.buy_orders.order('price desc').limit(to_be_destroyed).destroy_all
      end
    end
  end
end
