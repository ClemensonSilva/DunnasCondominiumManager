class Apartment < ApplicationRecord
  belongs_to :building
  has_and_belongs_to_many :users, join_table: :apartments_users
  has_many :tickets, dependent: :destroy
end
