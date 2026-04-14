class RemoveCondominiumIdFromBuilding < ActiveRecord::Migration[8.1]
  def change
    remove_reference :buildings, :condominium, null: false, foreign_key: true
  end
end
