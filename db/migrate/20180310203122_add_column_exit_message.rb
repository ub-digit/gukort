class AddColumnExitMessage < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :exit_message, :string
  end
end
