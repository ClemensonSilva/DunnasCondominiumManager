class CreateScopes < ActiveRecord::Migration[8.1]
  def change
    create_table :scopes do |t|
      t.string :title

      t.timestamps
    end
  end
end
