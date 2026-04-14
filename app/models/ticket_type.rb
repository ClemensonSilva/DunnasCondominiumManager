class TicketType < ApplicationRecord
  belongs_to :scope
  validates :title, presence: true, uniqueness: true
  validates :sla_hours, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
