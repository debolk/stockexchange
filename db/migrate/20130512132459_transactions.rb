class Transactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :commodity, null: false
      t.integer :amount, :null => false
      t.integer :buy_price, :null => false
      t.integer :sell_price, :null => false
      t.timestamps
    end
  end
end
