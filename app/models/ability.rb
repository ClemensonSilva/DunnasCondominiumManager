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

    can %i[read update], User, id: user.id

    if user.colaborator?
      can %i[read update], Ticket, ticket_type: { scope_id: user.scope_ids }
      can :read, Comment, ticket: { ticket_type: { scope_id: user.scope_ids } }
      can :create, Comment, ticket: { ticket_type: { scope_id: user.scope_ids } }
      can %i[update destroy], Comment,
          user_id: user.id,
          ticket: { ticket_type: { scope_id: user.scope_ids } }
      return
    end

    if user.resident?
      can :read, [ Building ]
      can :create, Ticket
      can %i[read update destroy], Ticket, apartment_id: user.apartment_ids
      can :read, Comment, ticket: { apartment_id: user.apartment_ids }
      can :create, Comment, ticket: { apartment_id: user.apartment_ids }
      can %i[update destroy], Comment,
          user_id: user.id,
          ticket: { apartment_id: user.apartment_ids }
      nil
    end
  end
end
