class AddPrivateToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :private, :boolean, default: false, null: false
  end
end
