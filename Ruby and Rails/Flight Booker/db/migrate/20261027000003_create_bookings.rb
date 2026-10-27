class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      t.integer :flight_id, null: false
      t.string :booking_reference, null: false

      t.timestamps
    end

    add_foreign_key :bookings, :flights
    add_index :bookings, :flight_id
    add_index :bookings, :booking_reference, unique: true
  end
end
