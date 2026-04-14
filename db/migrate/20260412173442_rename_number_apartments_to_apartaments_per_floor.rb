class RenameNumberApartmentsToApartamentsPerFloor < ActiveRecord::Migration[8.1]
  def change
    rename_column :buildings, :number_of_apartments, :apartments_per_floor
  end
end
