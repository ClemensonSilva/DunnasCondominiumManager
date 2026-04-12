class Building < ApplicationRecord
  has_many :apartments, dependent: :destroy
  validates :name, presence: true
  validates :number_of_floors, presence: true, numericality: { only_integer: true, greater_than: 0 , less_than_or_equal_to: 100 }
  validates :apartments_per_floor, presence: true, numericality: { only_integer: true, greater_than: 0 , less_than_or_equal_to: 10 }

  after_create :creating_apartments

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
