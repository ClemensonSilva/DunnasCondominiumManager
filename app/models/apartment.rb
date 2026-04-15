class Apartment < ApplicationRecord
  belongs_to :building
  has_and_belongs_to_many :users, join_table: :apartments_users
  has_many :tickets, dependent: :destroy

  def label_with_building
    "#{building&.name} - #{identificator}"
  end
end
