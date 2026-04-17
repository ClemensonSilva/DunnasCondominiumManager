class Building < ApplicationRecord
  validates :name, presence: true, length: { maximum: 25, message: "O nome do prédio deve ter no máximo %{count} caracteres." }
  validates :number_of_floors, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }

  validates :apartments_per_floor, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10, message: "O número de apartamentos por andar deve ser um número inteiro entre 1 e 10." }
  has_many :apartments, dependent: :destroy
  has_many :tickets, through: :apartments

  scope :tickets_building, -> { joins(apartments: :tickets).distinct }
  scope :with_residents, -> { joins(apartments: :users).merge(User.residents).distinct }

  scope :tickets_building_open, -> {
    default_status = TicketStatus.find_by(is_default: true)
    next none unless default_status

    tickets_building.where(tickets: { ticket_status_id: default_status.id })
  }

  scope :residents, -> { with_residents }

  scope :search_by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
end
