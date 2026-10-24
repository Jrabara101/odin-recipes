class AddCreatorToEvents < ActiveRecord::Migration[7.2]
  def change
    add_reference :events, :creator, null: false, foreign_key: { to_table: :users }
  end
end
