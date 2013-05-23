class CommodityHasSupplyAmount < ActiveRecord::Migration
  def change
    add_column :commodities, :supply_amount, :integer, default: 0
  end
end
