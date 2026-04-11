class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :apartment, null: false, foreign_key: true
      t.references :ticket_status, null: false, foreign_key: true
      t.references :ticket_type, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :attachments
      t.datetime :finished_at

      t.timestamps
    end
  end
end
