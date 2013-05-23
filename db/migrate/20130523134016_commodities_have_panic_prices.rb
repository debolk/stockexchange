class CommoditiesHavePanicPrices < ActiveRecord::Migration
  def change
    add_column :commodities, :panic_price, :integer, null: false, default: 300
    add_column :commodities, :panic_variance, :integer, null: false, default: 50
  end
end
