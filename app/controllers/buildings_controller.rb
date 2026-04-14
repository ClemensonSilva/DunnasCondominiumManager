class BuildingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_building, only: %i[ show edit update destroy ]

  # GET /buildings or /buildings.json
  def index
    if current_user&.admin?
          @buildings = Building.all
    end

    if current_user.resident?
      @buildings = User.find(current_user.id).buildings_of_resident
    end
    if current_user.colaborator?
      scope = User.find(current_user.id).scopes.first
      @buildings = Building.joins(:tickets)
                           .where(tickets: { scope_id: scope.id })
                           .distinct

    end
  end
  # GET /buildings/search_by_name usado pelo Stimulus para buscar por nome
  def search_by_name
    @buildings = Building.search_by_name(params[:name])
    render :index
  end

  # GET /buildings/1 or /buildings/1.json
  def show
    stats = BuildingStatistics.new(@building)

    @tickets = stats.tickets_for_show
    @tickets_count = @tickets.size
    @residents_count = stats.residents_count

    return unless current_user&.admin?

    @total_apartments = stats.total_apartments
    @occupied_apartments_count = stats.occupied_apartments_count
    @occupancy_rate = stats.occupancy_rate
    @closed_tickets_count = stats.closed_tickets_count(@tickets)
    @open_tickets_count = stats.open_tickets_count(@tickets)
    @overdue_tickets_count = stats.overdue_tickets_count(@tickets)
    @average_resolution_hours = stats.average_resolution_hours(@tickets)
    @top_ticket_types = stats.top_ticket_types(3, @tickets)
    @collaborator_activity = stats.collaborator_activity(3, @tickets)
    @last_ticket_created_at = stats.last_ticket_created_at(@tickets)
    @last_ticket_updated_at = stats.last_ticket_updated_at(@tickets)
  end

  # GET /buildings/new
  def new
    @building = Building.new
  end

  # GET /buildings/1/edit
  def edit
  end

  # POST /buildings or /buildings.json
  def create
    @building = Building.new(building_params)

    respond_to do |format|
      if @building.save
        format.html { redirect_to @building, notice: "Building was successfully created." }
        format.json { render :show, status: :created, location: @building }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /buildings/1 or /buildings/1.json
  def update
    respond_to do |format|
      if @building.update(building_params)
        format.html { redirect_to @building, notice: "Building was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @building }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buildings/1 or /buildings/1.json
  def destroy
    @building.destroy!

    respond_to do |format|
      format.html { redirect_to buildings_path, notice: "Building was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = Building.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def building_params
      params.expect(building: [ :name, :apartments_per_floor, :number_of_floors ])
    end
end
