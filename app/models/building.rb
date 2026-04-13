class Building < ApplicationRecord
  has_many :apartments, dependent: :destroy
  has_many :tickets, through: :apartments
  validates :name, presence: true
  validates :number_of_floors, presence: true, numericality: { only_integer: true, greater_than: 0 , less_than_or_equal_to: 100 }
  validates :apartments_per_floor, presence: true, numericality: { only_integer: true, greater_than: 0 , less_than_or_equal_to: 10 }

  after_create :creating_apartments

  scope :tickets_building, -> { joins(apartments: :tickets).distinct }

  scope :tickets_building_open, -> {
    default_status = TicketStatus.find_by(is_default: true)
    next none unless default_status

    tickets_building.where(tickets: { ticket_status_id: default_status.id })
  }
  
  scope :residents, -> { joins(apartments: :users).where(users: { user_type: :resident }).distinct }

  def self.tickets_for_show(building_id)
    Ticket
      .joins(apartment: :building)
      .merge(where(id: building_id).tickets_building)
      .includes(:ticket_status, :ticket_type, :user, :apartment)
      .order(created_at: :desc)
  end

  def self.residents_count_for(building_id)
    where(id: building_id).residents.count("users.id")
  end
  

  private

  def creating_apartments
    (1..number_of_floors).each do |floor|
      (1..apartments_per_floor).each do |position|
        apartments << Apartment.new(
          floor: floor,
          identificator: "Apartamento #{floor}#{position}"
        )
      end
    end
  end

  

end
