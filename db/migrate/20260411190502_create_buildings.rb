class CreateBuildings < ActiveRecord::Migration[8.1]
  def change
    create_table :buildings do |t|
      t.string :name
      t.references :condominium, null: false, foreign_key: true
      t.integer :number_of_apartments
      t.integer :number_of_floors

      t.timestamps
    end
  end
end
