class CreateJoinTableUsersApartments < ActiveRecord::Migration[8.1]
  def change
    create_join_table :users, :apartments do |t|
      # t.index [:user_id, :apartment_id]
      # t.index [:apartment_id, :user_id]
    end
  end
end
