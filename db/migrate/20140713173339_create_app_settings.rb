class CreateAppSettings < ActiveRecord::Migration
  def change
    create_table :app_settings do |t|
      t.string :set_key
      t.string :set_val
    end
  end
end
