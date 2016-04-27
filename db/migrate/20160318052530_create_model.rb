class CreateModel < ActiveRecord::Migration
  def change
    create_table :hikes do |t|
      t.string :hike_name
      t.float :roundtrip_distance
      t.float :elevation_gain
      t.float :highest_point
      t.string :trailhead_coordinates
      t.string :required_passes
      t.string :image_url
      t.string :trail_attributes
      t.string :region
      t.float :miles_from_seattle
      t.integer :minutes_from_seattle
      t.string :hike_url
      t.text :summary
      t.string :hike_id
    end
  end
end