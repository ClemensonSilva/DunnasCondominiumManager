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

  test "take_by! assigns collaborator when ticket is available" do
    collaborator = User.create!(
      name: "Collaborator Take",
      email: "take_#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      user_type: :colaborator
    )

    ticket = Ticket.create!(
      user: users(:one),
      apartment: apartments(:one),
      ticket_status: ticket_statuses(:one),
      ticket_type: ticket_types(:one),
      title: "Ticket available",
      description: "Test",
      attachments: "-"
    )

    assert ticket.take_by!(collaborator)
    assert_equal collaborator, ticket.reload.collaborator
  end

  test "close! marks ticket as finished with closed status" do
    collaborator = User.create!(
      name: "Collaborator Close",
      email: "close_#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      user_type: :colaborator
    )

    closed_status = TicketStatus.create!(title: Ticket::CLOSED_STATUS_TITLE, is_default: false)

    ticket = Ticket.create!(
      user: users(:one),
      apartment: apartments(:one),
      ticket_status: ticket_statuses(:one),
      ticket_type: ticket_types(:one),
      title: "Ticket to close",
      description: "Test",
      attachments: "-"
    )

    assert ticket.close!(collaborator)

    ticket.reload
    assert_not_nil ticket.finished_at
    assert_equal closed_status, ticket.ticket_status
    assert_equal collaborator, ticket.collaborator
  end
end
