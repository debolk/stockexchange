class AddBuyorderState < ActiveRecord::Migration
  def change
    add_column :buy_orders, :state, :string, null: false, default: :open
  end
end
