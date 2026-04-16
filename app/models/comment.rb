class Comment < ApplicationRecord
  validates :content, presence: true, length: { maximum: 200, message: "O comentário deve ter no máximo %{count} caracteres." }
  validates :user, presence: true
  validates :ticket, presence: true
  belongs_to :user, dependent: :destroy
  belongs_to :ticket, dependent: :destroy
end
