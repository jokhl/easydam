class CreateRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :roles do |t|
      t.string      :name, null: false
      t.string      :description
      t.text        :permissions, array: true, default: []
      t.boolean     :system_role, default: true
      
      t.belongs_to  :resource, index: true, polymorphic: true

      t.timestamps
    end
  end
end
