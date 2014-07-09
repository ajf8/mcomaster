class CreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies do |t|
      t.string :policy
      t.string :agent
      t.string :callerid
      t.string :action
    end
  end
end
