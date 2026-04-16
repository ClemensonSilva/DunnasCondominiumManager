module TicketsHelper
  def ticket_person_display(user, fallback = "-")
    user&.name.presence || user&.email.presence || fallback
  end

  def ticket_datetime_display(datetime)
    datetime ? l(datetime, format: :short) : "-"
  end

  def can_take_ticket?(ticket)
    current_user&.colaborator? && ticket.available_for_pickup? && can?(:take, ticket)
  end

  def can_finalize_ticket?(ticket)
    can?(:finalize, ticket) && !ticket.already_finalized?
  end
end
