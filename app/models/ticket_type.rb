class TicketType < ApplicationRecord
  belongs_to :scope
  has_many :tickets, dependent: :destroy
  validates_uniqueness_of :title, scope: :scope_id
  validates :title, presence: true, length: { maximum: 50, message: "O título do tipo de ticket deve ter no máximo %{count} caracteres." }
  validates :sla_hours, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
