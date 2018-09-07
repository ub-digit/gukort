class AddIndexToPatronsTable < ActiveRecord::Migration[5.1]
  def change
    add_index :patrons, :personalnumber
    add_index :patrons, :library_cardnumber
  end
end
