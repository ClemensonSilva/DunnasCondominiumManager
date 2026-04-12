# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    super()

    user ||= User.new

    return unless user.persisted?

    if user.admin?
      can :manage, :all
      return
    end

    can :read, [ Building, Scope, TicketStatus, TicketType ]
    can %i[read update], User, id: user.id

    if user.colaborator?
      can %i[read update], Ticket, ticket_type: { scope_id: user.scope_ids }
      can :manage, Comment, user_id: user.id
      can :read, Comment, ticket: { ticket_type: { scope_id: user.scope_ids } }
      return
    end

    if user.resident?
      can :manage, Ticket, user_id: user.id
      can :manage, Comment, user_id: user.id
      return
    end
  end
end
