class Apartment < ApplicationRecord
  belongs_to :building
  has_many :tickets, dependent: :destroy
end
