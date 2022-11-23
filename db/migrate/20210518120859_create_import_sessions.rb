class CreateImportSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :import_sessions do |t|
      t.datetime  :finished_at
      t.integer   :assets_count, null: false, default: 0
      t.integer   :not_allowed_count, null: false, default: 0
      t.integer   :status, default: 0
      t.string    :remark
      t.jsonb     :details, default: {}

      t.timestamps
    end
  end
end
