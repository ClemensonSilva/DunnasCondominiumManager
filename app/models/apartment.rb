class Apartment < ApplicationRecord
  # validações
  validates :identificator, presence: true, uniqueness: { scope: :building_id }
  validates :building, presence: true
  # associações
  belongs_to :building
  has_and_belongs_to_many :users, join_table: :apartments_users
  has_many :tickets, dependent: :destroy

  def label_with_building
    "#{building&.name} - #{identificator}"
  end
end
