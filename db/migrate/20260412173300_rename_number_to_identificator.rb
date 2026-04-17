class RenameNumberToIdentificator < ActiveRecord::Migration[8.1]
  def change
    rename_column :apartments, :number, :identificator
  end
end
