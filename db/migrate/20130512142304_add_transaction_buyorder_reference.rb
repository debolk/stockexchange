class AddTransactionBuyorderReference < ActiveRecord::Migration
  def change
    add_column :transactions, :buy_order_id, :integer
  end
end
