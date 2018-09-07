class CreatePatrons < ActiveRecord::Migration[5.1]
  def change
    create_table :patrons do |t|
      t.text :personalnumber
      t.text :library_cardnumber
      t.boolean :deleted

      t.timestamps
    end
  end
end
