class ForgottenColumns < ActiveRecord::Migration
  def change
    add_column :commodities, :deleted_at, :timestamp
    add_column :buy_orders, :commodity_id, :integer
  end
end
