class Scope < ApplicationRecord
  validates :title, presence: true, uniqueness: true, length: { maximum: 50 }
  has_and_belongs_to_many :users, join_table: :scopes_users
end
