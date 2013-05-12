class CommodityMarkup < ActiveRecord::Migration
  def change
    add_column :commodities, :markup, :integer, :null => false, :default => 100
  end
end
