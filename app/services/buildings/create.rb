module Buildings
  class Create
    def initialize(building_params)
      @building_params = building_params
    end

    def call
      building = Building.new(@building_params)
      return building unless building.valid?

      Building.transaction do
        building.save!
        insert_apartments!(building)
      end

      building
    end

    private

    def insert_apartments!(building)
      rows = []
      timestamp = Time.current

      1.upto(building.number_of_floors) do |floor|
        1.upto(building.apartments_per_floor) do |position|
          rows << {
            building_id: building.id,
            floor: floor,
            identificator: "Apartamento #{floor}#{position}",
            created_at: timestamp,
            updated_at: timestamp
          }
        end
      end

      Apartment.insert_all!(rows) if rows.any?
    end
  end
end
