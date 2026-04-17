module Comments
  class IndexQuery
    def initialize(ticket:, ability:)
      @ticket = ticket
      @ability = ability
    end

    def call
      @ticket.comments
        .accessible_by(@ability, :read)
        .includes(:user, files_attachments: :blob)
        .order(created_at: :asc)
    end
  end
end
