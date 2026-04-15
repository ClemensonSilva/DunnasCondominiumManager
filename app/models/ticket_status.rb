class TicketStatus < ApplicationRecord
   validates :title, presence: true, uniqueness: true
  # TODO implementar lógica para impedir adição de mais de um status padrão
end
