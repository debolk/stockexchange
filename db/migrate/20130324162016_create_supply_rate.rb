class CreateSupplyRate < ActiveRecord::Migration
  def change
    add_column :commodities, :supply_rate, :integer, null: false, default: 0
    add_column :commodities, :supply_price, :integer, null: false, default: 0
    add_column :commodities, :supply_last, :timestamp 
  end
end
