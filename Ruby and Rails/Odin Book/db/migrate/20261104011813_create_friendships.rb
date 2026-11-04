class CreateFriendships < ActiveRecord::Migration[7.2]
  def change
    create_table :friendships do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.string :status, default: "pending", null: false

      t.timestamps
    end

    add_index :friendships, [:sender_id, :receiver_id], unique: true
    add_index :friendships, :status
  end
end
