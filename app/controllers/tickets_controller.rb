class TicketsController < ApplicationController
  load_and_authorize_resource
  before_action :set_ticket, only: %i[ show edit update destroy take finalize ]
  before_action :prepare_wizard_collections, only: %i[ new edit create update ]
  before_action :prepare_ticket_edit_collections, only: %i[ edit update ]

  # GET /tickets or /tickets.json
  def index
    filters = Tickets::FormOptions.new(user: current_user).index_filters
    @ticket_status_filter_options = filters[:ticket_status_filter_options]
    @ticket_type_filter_options = filters[:ticket_type_filter_options]
    @apartment_filter_options = filters[:apartment_filter_options]

    @tickets = Tickets::IndexQuery.new(
      ability: current_ability,
      params: params
    ).call
  end

  # GET /tickets/1 or /tickets/1.json
  def show
    @comments = @ticket.comments.includes(:user, files_attachments: :blob)
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
        format.html { redirect_to @ticket, notice: "Ticket criado com sucesso." }
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
        format.html { redirect_to @ticket, notice: "Ticket atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @ticket }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /tickets/1/finalize
  def finalize
    authorize! :finalize, @ticket

    if @ticket.close!(current_user)
      redirect_to @ticket, notice: "Ticket marcado como concluído com sucesso às #{l(@ticket.finished_at, format: :short)}.", status: :see_other
    else
      redirect_to @ticket, alert: "Este ticket nao pode ser marcado como concluído.", status: :see_other
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
      format.html { redirect_to tickets_path, notice: "Ticket excluido com sucesso.", status: :see_other }
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
        params.expect(ticket: [ :apartment_id, :ticket_type_id, :title, :description, files: [] ])
      else
        # Permitir que colaboradores e admins atualizem o status e a data de conclusão dos tickets apenas, dando total dominio do ticket ao criador, evitando confusão e erros
        params.expect(ticket: [ :ticket_status_id, :finished_at ])
      end
    end
    ## Vou refatorar e tirar isso daqui
    def prepare_wizard_collections
      wizard_options = Tickets::FormOptions.new(user: current_user).wizard

      @apartment_options = wizard_options[:apartment_options]
      @ticket_type_options = wizard_options[:ticket_type_options]
      @ticket_type_sla_map = wizard_options[:ticket_type_sla_map]
    end

    def assign_ticket_defaults(ticket)
      ticket.user ||= current_user
      ticket.ticket_status ||= TicketStatus.find_by(is_default: true) || TicketStatus.first
    end

    def prepare_ticket_edit_collections
      edit_options = Tickets::FormOptions.new(user: current_user).edit

      @edit_apartment_options = edit_options[:edit_apartment_options]
      @edit_ticket_type_options = edit_options[:edit_ticket_type_options]
      @edit_ticket_status_options = edit_options[:edit_ticket_status_options]
    end
end
