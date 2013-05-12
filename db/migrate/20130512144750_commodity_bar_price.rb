class CommodityBarPrice < ActiveRecord::Migration
  def change
    add_column :commodities, :bar_price, :integer, :null => false
  end
end
