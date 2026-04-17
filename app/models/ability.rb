# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    return unless user.persisted?

    can %i[read update], User, id: user.id

    if user.admin?
      admin_abilities
    elsif user.colaborator?
      collaborator_abilities(user)
    elsif user.resident?
      resident_abilities(user)
    end
  end

  private

  def admin_abilities
    can :manage, :all
  end

  def collaborator_abilities(user)
    can :read, Ticket, ticket_type: { scope_id: user.scope_ids }

    can :take, Ticket,
        ticket_type: { scope_id: user.scope_ids },
        finished_at: nil,
        collaborator_id: nil

    can :finalize, Ticket,
        collaborator_id: user.id,
        finished_at: nil

    can %i[read create], Comment, ticket: { ticket_type: { scope_id: user.scope_ids } }

    can %i[update destroy], Comment,
        user_id: user.id,
        ticket: { ticket_type: { scope_id: user.scope_ids } }
  end

  def resident_abilities(user)
    can :read, Building

    can :create, Ticket
    can %i[read update destroy], Ticket, apartment_id: user.apartment_ids

    can %i[read create], Comment, ticket: { apartment_id: user.apartment_ids }

    can %i[update destroy], Comment,
        user_id: user.id,
        ticket: { apartment_id: user.apartment_ids }
  end
end
