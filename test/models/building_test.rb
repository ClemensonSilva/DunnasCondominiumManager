require "test_helper"

class BuildingTest < ActiveSupport::TestCase
  test "should not save building with more than 100 floors" do
    building = Building.new(name: "Test Building", number_of_floors: 101, apartments_per_floor: 5)
    assert_not building.valid?
  end

  test "should not save building with more than 10 apartments per floor" do
    building = Building.new(name: "Test Building", number_of_floors: 10, apartments_per_floor: 11)
    assert_not building.valid?
  end

  test "should not create apartments automatically" do
    building = Building.create(name: "Test Building", number_of_floors: 2, apartments_per_floor: 3)
    assert_equal 0, building.apartments.count
  end
end
