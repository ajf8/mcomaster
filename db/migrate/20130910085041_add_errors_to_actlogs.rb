class AddErrorsToActlogs < ActiveRecord::Migration
  def change
    add_column :actlogs, :mcerr, :text
  end
end
