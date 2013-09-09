class CreateAudit < ActiveRecord::Migration
  def change
    create_table :actlogs do |t|
      t.text :args
      t.text :stats
      t.text :filters
      t.string :txid
      t.string :agent
      t.string :action
      t.integer :ok
      t.integer :failed
      t.string :owner
      t.timestamps
    end
    create_table :responselogs do |t|
      t.belongs_to :actlog
      t.string :name
      t.integer :status
      t.string :statusmsg
      t.timestamps
    end
    create_table :reply_items do |t|
      t.belongs_to :responselog
      t.string :rkey
      t.string :rvalue
    end
  end
end
