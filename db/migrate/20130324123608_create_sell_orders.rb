class CreateSellOrders < ActiveRecord::Migration
  def change
    create_table :sell_orders do |t|
      t.string :seller
      t.references :commodity, null: false
      t.integer :amount, null: false
      t.integer :price, null: false
      t.timestamp :deleted_at
      t.timestamps
    end

    add_column :buy_orders, :deleted_at, :timestamp
    add_column :commodities, :buyback_price, :integer, null: false, default: 0
  end
end
