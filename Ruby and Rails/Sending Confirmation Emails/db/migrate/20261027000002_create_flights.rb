class CreateFlights < ActiveRecord::Migration[7.2]
  def change
    create_table :flights do |t|
      t.integer :departure_airport_id, null: false
      t.integer :arrival_airport_id, null: false
      t.datetime :start_datetime, null: false
      t.integer :duration, null: false
      t.string :flight_number, null: false

      t.timestamps
    end

    add_foreign_key :flights, :airports, column: :departure_airport_id
    add_foreign_key :flights, :airports, column: :arrival_airport_id
    add_index :flights, :departure_airport_id
    add_index :flights, :arrival_airport_id
    add_index :flights, [:departure_airport_id, :arrival_airport_id]
    add_index :flights, :start_datetime
  end
end
