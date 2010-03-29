class CreateFirbNotes < ActiveRecord::Migration
  def self.up
    create_table :firb_notes do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :firb_notes
  end
end
