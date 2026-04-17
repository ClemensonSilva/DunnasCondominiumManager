class Ticket < ApplicationRecord
  CLOSED_STATUS_TITLE = "Fechado".freeze
  ALLOWED_FILE_TYPES = [ "image/png", "image/jpeg", "application/pdf" ].freeze
  MAX_FILE_SIZE = 4.megabytes

  belongs_to :user
  belongs_to :collaborator, class_name: "User", optional: true
  belongs_to :apartment
  belongs_to :ticket_status
  belongs_to :ticket_type

  has_many :comments, dependent: :destroy
  has_many_attached :files, dependent: :destroy

  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 200 }

  validate :validate_files
  validate :collaborator_must_be_a_collaborator_role
  validate :colaborator_must_be_inside_scope_of_ticket

  after_initialize :set_default_status, if: :new_record?

  scope :recent_first, -> { order(created_at: :desc) }
  scope :with_status, ->(status_id) { where(ticket_status_id: status_id) if status_id.present? }
  scope :with_ticket_type, ->(type_id) { where(ticket_type_id: type_id) if type_id.present? }
  scope :with_apartment, ->(apartment_id) { where(apartment_id: apartment_id) if apartment_id.present? }
  scope :for_index, -> { includes(:ticket_status, :ticket_type, :user, :apartment, :collaborator) }

  scope :with_collaborator_state, ->(state) do
    case state&.to_sym
    when :assigned   then where.not(collaborator_id: nil)
    when :unassigned then where(collaborator_id: nil)
    else all
    end
  end

  def already_finalized?
    finished_at.present?
  end

  def available_for_pickup?
    finished_at.blank? && collaborator_id.blank?
  end

  def take_by!(user)
    return false unless user&.colaborator?

    with_lock do
      return false unless available_for_pickup?

      update!(collaborator: user)
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def update_status!(new_status)
    update!(ticket_status: new_status)
  end

  # Explicit business command to close a ticket in one place.
  def close!(user)
    with_lock do
      reload
      return false if already_finalized?

      closed_status = TicketStatus.find_by(title: CLOSED_STATUS_TITLE)
      return false unless closed_status

      attributes = {
        finished_at: Time.current,
        ticket_status: closed_status
      }

      attributes[:collaborator] = user if user&.colaborator?

      update!(attributes)
    end
  rescue ActiveRecord::RecordInvalid
    false
  end


  private

  def validate_files
    return unless files.attached?

    files.each do |file|
      unless ALLOWED_FILE_TYPES.include?(file.blob.content_type)
        errors.add(:files, "deve conter apenas PNG, JPEG ou PDF")
      end

      if file.blob.byte_size > MAX_FILE_SIZE
        errors.add(:files, "deve conter arquivos menores que 4MB")
      end
    end
  end

  def set_default_status
    self.ticket_status ||= TicketStatus.find_by(is_default: true)
  end
  def colaborator_must_be_inside_scope_of_ticket
    return if collaborator_id.blank? || ticket_type_id.blank?

    unless collaborator&.scopes&.include?(ticket_type.scope)
      errors.add(:collaborator, "deve ter escopo compatível com o tipo do ticket")
    end
  end

  def collaborator_must_be_a_collaborator_role
    return if collaborator_id.blank?

    unless collaborator&.colaborator?
      errors.add(:collaborator, "deve ter a role de colaborador")
    end
  end
end
