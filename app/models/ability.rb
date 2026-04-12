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
    can :manage, Ticket, user_id: user.id
    can :manage, Comment, user_id: user.id
    can %i[read update], User, id: user.id
  end
end
