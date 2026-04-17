class TicketStatus < ApplicationRecord
   validates :title, presence: true, uniqueness: true
   validates_uniqueness_of :is_default, conditions: -> { where(is_default: true) }, if: :is_default
   has_many :tickets, dependent: :destroy
  # TODO implementar lógica para impedir adição de mais de um status padrão
end
