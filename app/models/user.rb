class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :user_type, { admin: 0, resident: 1, colaborator: 2 }
  has_and_belongs_to_many :scopes, join_table: :scopes_users
  has_many :tickets
  has_many :comments
end
