class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :name
      t.timestamps
    end

    create_table :filter_members do |t|
      t.string :term
      t.string :filtertype
      t.string :term_key
      t.string :term_operator
      t.belongs_to :filter
      t.timestamps
    end
  end
end
