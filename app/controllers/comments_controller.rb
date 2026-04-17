class CommentsController < ApplicationController
  before_action :set_ticket
  before_action :set_comment, only: %i[ show edit update destroy ]
  before_action :authorize_ticket_access!
  before_action :authorize_comment_read!, only: %i[ show ]
  before_action :authorize_comment_update!, only: %i[ edit update ]
  before_action :authorize_comment_destroy!, only: %i[ destroy ]
  before_action :ensure_ticket_open!, only: %i[ new create ]

  # GET /comments or /comments.json
  def index
    @comments = Comments::IndexQuery.new(ticket: @ticket, ability: current_ability).call

    @close_path = modal_close_path
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new(user: current_user, ticket: @ticket)
    authorize! :create, @comment
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
  def create
    @comment = @ticket.comments.build(comment_params)
    @comment.user = current_user
    authorize! :create, @comment

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @ticket, notice: "Comentário adicionado com sucesso.", status: :see_other }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to ticket_comment_path(@ticket, @comment), notice: "Comentário atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @comment.destroy!

    respond_to do |format|
      format.html { redirect_to ticket_comments_path(@ticket), notice: "Comentário excluído com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = @ticket.comments.find(params.expect(:id))
    end

    def set_ticket
      @ticket = Ticket.find(params.expect(:ticket_id))
    end

    def authorize_ticket_access!
      authorize! :read, @ticket
    end

    def authorize_comment_read!
      authorize! :read, @comment
    end

    def authorize_comment_update!
      authorize! :update, @comment
    end

    def authorize_comment_destroy!
      authorize! :destroy, @comment
    end

    def ensure_ticket_open!
      return unless @ticket.finished_at.present?

      redirect_to @ticket, alert: "Não é possível adicionar comentários a um chamado finalizado."
    end

    def modal_close_path
      return ticket_path(@ticket) if params[:return_to].blank?

      candidate = params[:return_to].to_s
      uri = URI.parse(candidate)
      return ticket_path(@ticket) if uri.scheme.present? || uri.host.present?

      candidate.start_with?("/") ? candidate : ticket_path(@ticket)
    rescue URI::InvalidURIError
      ticket_path(@ticket)
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.expect(comment: [ :content, files: [] ])
    end
end
