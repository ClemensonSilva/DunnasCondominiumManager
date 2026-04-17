class AddCollaboratorToTickets < ActiveRecord::Migration[8.1]
  def change
    add_reference :tickets, :collaborator, null: true, foreign_key: {to_table: :users}
  end
end
