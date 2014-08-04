class FixPolicyActionColumn < ActiveRecord::Migration
  def change
    rename_column :policies, :action, :action_name
  end
end
