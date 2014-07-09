class CreatePolicyDefaults < ActiveRecord::Migration
  def change
    create_table :policy_defaults do |t|
      t.string :name
      t.string :policy
    end
  end
end
