class CreateJoinTableUserScope < ActiveRecord::Migration[8.1]
  def change
    create_join_table :scopes, :users do |t|
      # t.index [:scope_id, :user_id]
      # t.index [:user_id, :scope_id]
    end
  end
end
