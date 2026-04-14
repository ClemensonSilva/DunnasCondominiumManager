class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :user_type, { admin: 0, resident: 1, colaborator: 2 }, default: :resident
  has_and_belongs_to_many :scopes, join_table: :scopes_users
  has_and_belongs_to_many :apartments, join_table: :apartments_users
  has_many :tickets
  has_many :comments

  scope :residents, -> { where(user_type: :resident) }
  scope :colaborators, -> { where(user_type: :colaborator) }

  def buildings_of_resident
    return nil unless resident?

    Building.joins(apartments: :users)
            .where(users: { id: id })
            .distinct
  end
end
