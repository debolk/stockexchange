class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.string :value
      t.timestamps
    end

    Setting.create(key: 'mode', value: 'normal')
  end
end
