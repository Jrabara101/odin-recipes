class CreateAirports < ActiveRecord::Migration[7.2]
  def change
    create_table :airports do |t|
      t.string :code, null: false
      t.string :city, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :airports, :code, unique: true
  end
end
