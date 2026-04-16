class UsersController < ApplicationController
  load_and_authorize_resource
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :prepare_form_collections, only: %i[ new create edit update ]

  # GET /users or /users.json
  def index
    @users_title = "Usuarios"
    @users = users_scope
  end

  def residents
    authorize! :read, User
    @users_title = "Residentes"
    @users = User.residents
    render :index
  end

  def colaborators
    authorize! :read, User
    @users_title = "Colaboradores"
    @users = User.colaborators
    render :index
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "Usuario foi criado com sucesso." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if update_user
        format.html { redirect_to @user, notice: "Usuario foi atualizado com sucesso.", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: "Usuario foi excluido com sucesso.", status: :see_other }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      if current_user&.admin?
        params.expect(user: [ :name, :email, :user_type, :password, :password_confirmation, { scope_ids: [], apartment_ids: [] } ])
      else
        params.expect(user: [ :name, :email, :password, :password_confirmation ])
      end
    end

    def users_scope
      User.accessible_by(current_ability, :read).includes(:scopes, :apartments)
    end

    def prepare_form_collections
      @available_scopes = Scope.order(:title)
      @available_apartments = Apartment.joins(:building)
                                       .includes(:building)
                                       .order("buildings.name ASC, apartments.identificator ASC")
    end

    def update_user
      if password_blank_for_update?
        @user.update_without_password(user_params.except(:password, :password_confirmation))
      else
        @user.update(user_params)
      end
    end

    def password_blank_for_update?
      user_params[:password].blank? && user_params[:password_confirmation].blank?
    end
end
