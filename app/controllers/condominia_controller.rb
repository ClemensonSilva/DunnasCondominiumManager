class CondominiaController < ApplicationController
  before_action :set_condominium, only: %i[ show edit update destroy ]

  # GET /condominia or /condominia.json
  def index
    @condominia = Condominium.all
  end

  # GET /condominia/1 or /condominia/1.json
  def show
  end

  # GET /condominia/new
  def new
    @condominium = Condominium.new
  end

  # GET /condominia/1/edit
  def edit
  end

  # POST /condominia or /condominia.json
  def create
    @condominium = Condominium.new(condominium_params)

    respond_to do |format|
      if @condominium.save
        format.html { redirect_to @condominium, notice: "Condominium was successfully created." }
        format.json { render :show, status: :created, location: @condominium }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @condominium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /condominia/1 or /condominia/1.json
  def update
    respond_to do |format|
      if @condominium.update(condominium_params)
        format.html { redirect_to @condominium, notice: "Condominium was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @condominium }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @condominium.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /condominia/1 or /condominia/1.json
  def destroy
    @condominium.destroy!

    respond_to do |format|
      format.html { redirect_to condominia_path, notice: "Condominium was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_condominium
      @condominium = Condominium.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def condominium_params
      params.expect(condominium: [ :name ])
    end
end
