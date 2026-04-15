require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "keeps apartment associations for resident users" do
    apartment = apartments(:one)
    user = User.new(
      name: "Resident Test",
      email: "resident_#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      user_type: :resident,
      apartment_ids: [ apartment.id ]
    )

    user.valid?

    assert_includes user.apartment_ids, apartment.id
  end

  test "removes apartment associations for non-resident users" do
    apartment = apartments(:one)
    user = User.new(
      name: "Collaborator Test",
      email: "colaborator_#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      user_type: :colaborator,
      apartment_ids: [ apartment.id ]
    )

    user.valid?

    assert_empty user.apartment_ids
  end

  test "nullifies collaborator on assigned tickets when deleting user" do
    owner = User.create!(
      name: "Owner Test",
      email: "owner_#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      user_type: :resident
    )

    collaborator = User.create!(
      name: "Collaborator Assigned",
      email: "assigned_#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      user_type: :colaborator
    )

    ticket = Ticket.create!(
      user: owner,
      collaborator: collaborator,
      apartment: apartments(:one),
      ticket_status: ticket_statuses(:one),
      ticket_type: ticket_types(:one),
      title: "Ticket with collaborator",
      description: "Test",
      attachments: "none"
    )

    collaborator.destroy!

    assert_nil ticket.reload.collaborator_id
  end
end
