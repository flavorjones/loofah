class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.column :title, :string
      t.column :body, :text
    end
  end
  
  def self.down
  end
end
