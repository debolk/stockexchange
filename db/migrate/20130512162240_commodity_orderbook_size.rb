class CommodityOrderbookSize < ActiveRecord::Migration
  def change
    add_column :commodities, :orderbook_size, :integer, :null => false, :default => 8
  end
end
