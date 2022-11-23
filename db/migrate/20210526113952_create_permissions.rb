class CreatePermissions < ActiveRecord::Migration[6.1]
  def change
    create_table :permissions do |t|
      t.string      :key, null: false
      t.string      :category

      t.timestamps
    end
  end
end
