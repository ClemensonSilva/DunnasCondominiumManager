require "test_helper"

class TicketTest < ActiveSupport::TestCase
  test "filters tickets with collaborator state" do
    collaborator = User.create!(
      name: "Collaborator Test",
      email: "collaborator_#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      user_type: :colaborator
    )

    assigned = Ticket.create!(
      user: users(:one),
      collaborator: collaborator,
      apartment: apartments(:one),
      ticket_status: ticket_statuses(:one),
      ticket_type: ticket_types(:one),
      title: "Assigned ticket",
      description: "Test",
      attachments: "-"
    )

    unassigned = Ticket.create!(
      user: users(:one),
      apartment: apartments(:two),
      ticket_status: ticket_statuses(:two),
      ticket_type: ticket_types(:two),
      title: "Unassigned ticket",
      description: "Test",
      attachments: "-"
    )

    assert_equal [ assigned.id ], Ticket.with_collaborator_state("assigned").pluck(:id)
    assert_equal [ unassigned.id ], Ticket.with_collaborator_state("unassigned").pluck(:id)

    assert_includes Ticket.with_status(ticket_statuses(:one).id), assigned
    assert_not_includes Ticket.with_status(ticket_statuses(:one).id), unassigned
  end
end
