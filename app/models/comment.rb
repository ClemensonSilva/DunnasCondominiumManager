class Comment < ApplicationRecord
  ALLOWED_FILE_TYPES = [ "image/png", "image/jpeg", "application/pdf" ].freeze
  MAX_FILE_SIZE = 4.megabytes

  validates :content, presence: true, length: { maximum: 200, message: "O comentário deve ter no máximo %{count} caracteres." }
  validates :user, presence: true
  validates :ticket, presence: true
  belongs_to :user
  belongs_to :ticket
  has_many_attached :files

  validate :validate_files

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
end
