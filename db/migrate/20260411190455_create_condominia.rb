class CreateCondominia < ActiveRecord::Migration[8.1]
  def change
    create_table :condominia do |t|
      t.string :name

      t.timestamps
    end
  end
end
