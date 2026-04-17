module Tickets
  class FormOptions
    def initialize(user:)
      @user = user
    end

    def index_filters
      {
        ticket_status_filter_options: TicketStatus.order(:title),
        ticket_type_filter_options: TicketType.order(:title),
        apartment_filter_options: apartments_for_filter
      }
    end

    def wizard
      ticket_types_scope = TicketType.includes(:scope).order(:title)

      {
        apartment_options: apartments_for_wizard.map do |apartment|
          building_name = apartment.building&.name.to_s
          apartment_label = apartment.identificator.to_s
          [ "#{building_name} - #{apartment_label}", apartment.id ]
        end,
        ticket_type_options: ticket_types_scope.map do |ticket_type|
          scope_title = ticket_type.scope&.title.to_s
          [ "#{scope_title} - #{ticket_type.title}", ticket_type.id ]
        end,
        ticket_type_sla_map: ticket_types_scope.each_with_object({}) do |ticket_type, map|
          map[ticket_type.id.to_s] = ticket_type.sla_hours
        end
      }
    end

    def edit
      {
        edit_apartment_options: apartments_for_edit,
        edit_ticket_type_options: TicketType.order(:title),
        edit_ticket_status_options: TicketStatus.order(:title)
      }
    end

    private

    def apartments_for_filter
      if @user&.resident?
        @user.apartments.includes(:building).order(:identificator)
      else
        Apartment.includes(:building).order(:identificator)
      end
    end

    def apartments_for_wizard
      if @user&.resident?
        @user.apartments.includes(:building).order(:identificator)
      else
        Apartment.includes(:building).order(:identificator)
      end
    end

    def apartments_for_edit
      if @user&.resident?
        @user.apartments.order(:identificator)
      else
        Apartment.order(:identificator)
      end
    end
  end
end
