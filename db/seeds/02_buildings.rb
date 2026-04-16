# db/seeds/02_buildings.rb

buildings_data = [
  { name: "Prédio A", number_of_floors: 6, apartments_per_floor: 4 },
  { name: "Prédio B", number_of_floors: 8, apartments_per_floor: 4 },
  { name: "Prédio C", number_of_floors: 10, apartments_per_floor: 4 }
]

buildings_data.each do |data|
  building = Building.create!(name: data[:name], number_of_floors: data[:number_of_floors], apartments_per_floor: data[:apartments_per_floor])

  data[:number_of_floors].times do |floor|
    data[:apartments_per_floor].times do |apt|
      # Gera identificadores como "101", "102", "1001", "1002"
      identificator = "#{floor + 1}#{(apt + 1).to_s.rjust(2, '0')}"
      building.apartments.create!(identificator: identificator)
    end
  end
end

puts "  ✓ #{Building.count} prédios criados"
puts "  ✓ #{Apartment.count} apartamentos criados"
