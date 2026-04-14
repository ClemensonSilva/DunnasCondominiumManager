require "test_helper"

class Buildings::CreateTest < ActiveSupport::TestCase
  test "creates building and apartments in a transaction" do
    assert_difference "Building.count", 1 do
      assert_difference "Apartment.count", 6 do
        building = Buildings::Create.new(
          name: "Test Building",
          number_of_floors: 2,
          apartments_per_floor: 3
        ).call

        assert_predicate building, :persisted?
      end
    end
  end

  test "returns invalid building without persisting when params are invalid" do
    building = Buildings::Create.new(
      name: "Test Building",
      number_of_floors: 0,
      apartments_per_floor: 3
    ).call

    assert_not_predicate building, :persisted?
    assert_not building.valid?
  end
end
