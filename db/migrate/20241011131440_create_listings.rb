class CreateListings < ActiveRecord::Migration[7.2]
  def change
    create_table :listings do |t|
      t.string :url, null: false
      t.integer :price
      t.integer :rating_count
      t.float :rating_value

      t.timestamps
    end

    add_index :listings, :url, unique: true
  end
end
