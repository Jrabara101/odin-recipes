class CreatePassengers < ActiveRecord::Migration[7.2]
  def change
    create_table :passengers do |t|
      t.integer :booking_id, null: false
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end

    add_foreign_key :passengers, :bookings
    add_index :passengers, :booking_id
    add_index :passengers, :email
  end
end
