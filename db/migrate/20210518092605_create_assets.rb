class CreateAssets < ActiveRecord::Migration[6.1]
  def change
    create_table :assets do |t|
      t.string      :title
      t.text        :description
      t.integer     :color_tag
      t.integer     :status, default: 0
      t.jsonb       :file_data

      t.belongs_to  :import_session, index: true

      t.timestamps
    end
  end
end
