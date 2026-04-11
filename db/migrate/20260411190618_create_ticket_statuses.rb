class CreateTicketStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_statuses do |t|
      t.string :title
      t.boolean :is_default

      t.timestamps
    end
  end
end
