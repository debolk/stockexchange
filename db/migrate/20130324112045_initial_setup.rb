class InitialSetup < ActiveRecord::Migration
  def change
    create_table :commodities do |t|
      t.string :name, :null => false
      t.integer :floor_price, :null => false, :default => 0
      t.integer :ceiling_price, :null => false, :default => 10
      t.timestamps
    end

    create_table :buy_orders do |t|
      t.string :phone
      t.integer :amount, :null => false
      t.integer :price, :null => false
      t.timestamps
    end
  end
end
