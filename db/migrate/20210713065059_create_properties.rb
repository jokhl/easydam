class CreateProperties < ActiveRecord::Migration[6.1]
  def change
    create_table :properties do |t|
      t.string    :key, null: false
      t.string    :name, null: false
      t.string    :prop_type, null: false

      t.timestamps
    end
  end
end
