class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.string :value
      t.timestamps
    end

    Setting.create(key: 'mode', value: 'normal')
    Setting.create(key: 'order_limit', value: '7')
  end
end
