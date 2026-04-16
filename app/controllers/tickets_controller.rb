class TicketsController < ApplicationController
  load_and_authorize_resource
  before_action :set_ticket, only: %i[ show edit update destroy take ]
  before_action :prepare_wizard_collections, only: %i[ new edit create update ]
  before_action :prepare_ticket_edit_collections, only: %i[ edit update ]

  # GET /tickets or /tickets.json
  def index
    @ticket_status_filter_options = TicketStatus.order(:title)
    @ticket_type_filter_options = TicketType.order(:title)
    @apartment_filter_options = accessible_apartments_for_index

    @tickets = Ticket.accessible_by(current_ability)
      .for_index
      .with_status(params[:ticket_status_id])
      .with_ticket_type(params[:ticket_type_id])
      .with_apartment(params[:apartment_id])
      .with_collaborator_state(params[:collaborator_state])
      .recent_first
  end

  # GET /tickets/1 or /tickets/1.json
  def show
    @comments = @ticket.comments
  end

  # GET /tickets/new
  def new
    @ticket = Ticket.new
    assign_ticket_defaults(@ticket)
  end

  # GET /tickets/1/edit
  def edit
  end

  # POST /tickets or /tickets.json
  def create
    @ticket = Ticket.new(ticket_params)
    assign_ticket_defaults(@ticket)

    respond_to do |format|
      if @ticket.save
        format.html { redirect_to @ticket, notice: "Ticket was successfully created." }
        format.json { render :show, status: :created, location: @ticket }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end
  # PATCH/PUT /tickets/1 or /tickets/1.json
  def update
    respond_to do |format|
      if @ticket.update(ticket_params)
        format.html { redirect_to @ticket, notice: "Ticket was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @ticket }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /tickets/1/take
  def take
    authorize! :take, @ticket

    if @ticket.take_by!(current_user)
      redirect_to @ticket, notice: "Ticket atribuido a voce com sucesso.", status: :see_other
    else
      redirect_to @ticket, alert: "Este ticket nao pode mais ser pego.", status: :see_other
    end
  end

  # DELETE /tickets/1 or /tickets/1.json
  def destroy
    @ticket.destroy!

    respond_to do |format|
      format.html { redirect_to tickets_path, notice: "Ticket was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def ticket_params
      if current_user&.resident? || (current_user&.admin? && action_name == "create")
        params.expect(ticket: [ :apartment_id, :ticket_type_id, :title, :description, :attachments ])
      else
        # Permitir que colaboradores e admins atualizem o status e a data de conclusão dos tickets apenas, dando total dominio do ticket ao criador, evitando confusão e erros
        params.expect(ticket: [ :ticket_status_id, :finished_at ])
      end
    end
    ## Vou refatorar e tirar isso daqui
    def prepare_wizard_collections
      apartments_scope = if current_user&.resident?
        current_user.apartments.includes(:building)
      else
        Apartment.includes(:building)
      end

      ticket_types_scope = TicketType.includes(:scope).order(:title)

      @apartment_options = apartments_scope.order(:identificator).map do |apartment|
        building_name = apartment.building&.name.to_s
        apartment_label = apartment.identificator.to_s
        [ "#{building_name} - #{apartment_label}", apartment.id ]
      end

      @ticket_type_options = ticket_types_scope.map do |ticket_type|
        scope_title = ticket_type.scope&.title.to_s
        [ "#{scope_title} - #{ticket_type.title}", ticket_type.id ]
      end

      @ticket_type_sla_map = ticket_types_scope.each_with_object({}) do |ticket_type, map|
        map[ticket_type.id.to_s] = ticket_type.sla_hours
      end
    end

    def assign_ticket_defaults(ticket)
      ticket.user ||= current_user
      ticket.ticket_status ||= TicketStatus.find_by(is_default: true) || TicketStatus.first
    end

    def accessible_apartments_for_index
      if current_user&.resident?
        current_user.apartments.includes(:building).order(:identificator)
      else
        Apartment.includes(:building).order(:identificator)
      end
    end

    def prepare_ticket_edit_collections
      @edit_apartment_options = if current_user&.resident?
        current_user.apartments.order(:identificator)
      else
        Apartment.order(:identificator)
      end

      @edit_ticket_type_options = TicketType.order(:title)
      @edit_ticket_status_options = TicketStatus.order(:title)
    end
end
