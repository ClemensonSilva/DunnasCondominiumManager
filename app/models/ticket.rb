class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :collaborator, class_name: "User", optional: true
  belongs_to :apartment
  belongs_to :ticket_status
  belongs_to :ticket_type
  has_many :comments, dependent: :destroy

  scope :recent_first, -> { order(created_at: :desc) }
  scope :with_status, ->(ticket_status_id) { ticket_status_id.present? ? where(ticket_status_id: ticket_status_id) : all }
  scope :with_ticket_type, ->(ticket_type_id) { ticket_type_id.present? ? where(ticket_type_id: ticket_type_id) : all }
  scope :with_apartment, ->(apartment_id) { apartment_id.present? ? where(apartment_id: apartment_id) : all }
  scope :with_collaborator_state, ->(state) {
    case state
    when "assigned"
      where.not(collaborator_id: nil)
    when "unassigned"
      where(collaborator_id: nil)
    else
      all
    end
  }
  scope :for_index, -> { includes(:ticket_status, :ticket_type, :user, :apartment, :collaborator) }
end
