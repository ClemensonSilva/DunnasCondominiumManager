class CreateTicketTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_types do |t|
      t.string :title
      t.integer :sla_hours
      t.references :scope, null: false, foreign_key: true

      t.timestamps
    end
  end
end
