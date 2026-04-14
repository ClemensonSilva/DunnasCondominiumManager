class TicketStatusesController < ApplicationController
  load_and_authorize_resource
  before_action :set_ticket_status, only: %i[ show edit update destroy ]

  # GET /ticket_statuses or /ticket_statuses.json
  def index
    @ticket_statuses = TicketStatus.all
  end

  # GET /ticket_statuses/1 or /ticket_statuses/1.json
  def show
  end

  # GET /ticket_statuses/new
  def new
    @ticket_status = TicketStatus.new
  end

  # GET /ticket_statuses/1/edit
  def edit
  end

  # POST /ticket_statuses or /ticket_statuses.json
  def create
    @ticket_status = TicketStatus.new(ticket_status_params)

    respond_to do |format|
      if @ticket_status.save
        format.html { redirect_to ticket_statuses_path, notice: "Status criado com sucesso." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ticket_statuses/1 or /ticket_statuses/1.json
  def update
    respond_to do |format|
      if @ticket_status.update(ticket_status_params)
        format.html { redirect_to ticket_statuses_path, notice: "Status de Ticket atualizado com sucesso!", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ticket_statuses/1 or /ticket_statuses/1.json
  def destroy
    @ticket_status.destroy!

    respond_to do |format|
      format.html { redirect_to ticket_statuses_path, notice: "Ticket status was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket_status
      @ticket_status = TicketStatus.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def ticket_status_params
      params.expect(ticket_status: [ :title, :is_default ])
    end
end
