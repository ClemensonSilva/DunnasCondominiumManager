class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum user_type: { admin: 0, resident: 1, colaborator: 2 }

  def admin?
    user_type.to_i == 0
  end

  def resident?
    user_type.to_i == 1
  end

  def colaborator?
    user_type.to_i == 2
  end
  
end
