class AddColumns < ActiveRecord::Migration
  def change
    add_column :hikes, :instagram_location_id, :string
    add_column :hikes, :instagram_tag, :string
    add_column :hikes, :transit_time, :integer
  end
end
