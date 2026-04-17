module Tickets
  class IndexQuery
    def initialize(ability:, params:)
      @ability = ability
      @params = params
    end

    def call
      Ticket.accessible_by(@ability)
        .for_index
        .with_status(@params[:ticket_status_id])
        .with_ticket_type(@params[:ticket_type_id])
        .with_apartment(@params[:apartment_id])
        .with_collaborator_state(@params[:collaborator_state])
        .recent_first
    end
  end
end
