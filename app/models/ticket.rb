class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :apartment
  belongs_to :ticket_status
  belongs_to :ticket_type
  has_many :comments, dependent: :destroy
end
