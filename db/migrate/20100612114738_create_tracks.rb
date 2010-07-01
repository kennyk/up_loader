class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string :id, :primary => true
      t.string :fileName, :limit => 36
      t.string :fileType, :limit => 10
      t.string :name
      t.string :id3Title
      t.string :id3Artist
      t.integer :id3Length
      t.datetime :uploaded

      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end
