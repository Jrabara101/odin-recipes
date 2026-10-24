class CreateEventAttendances < ActiveRecord::Migration[7.2]
  def change
    create_table :event_attendances do |t|
      t.references :attendee, null: false, foreign_key: { to_table: :users }
      t.references :attended_event, null: false, foreign_key: { to_table: :events }
      t.string :status, default: "attending", null: false

      t.timestamps
    end

    add_index :event_attendances, [:attendee_id, :attended_event_id], unique: true
  end
end
