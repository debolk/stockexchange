class Buyordername < ActiveRecord::Migration
  def change
    add_column :buy_orders, :owner, :string, null: false, default: ""
  end
end
