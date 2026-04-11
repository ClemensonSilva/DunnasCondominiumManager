class CreateApartments < ActiveRecord::Migration[8.1]
  def change
    create_table :apartments do |t|
      t.references :building, null: false, foreign_key: true
      t.integer :floor
      t.string :number

      t.timestamps
    end
  end
end
