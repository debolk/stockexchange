class UpdateOrders < ActiveRecord::Migration
  def change
    remove_column :sell_orders, :amount
    add_column :sell_orders, :state, :string, null: false, default: :open
  end
end
