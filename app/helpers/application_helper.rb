module ApplicationHelper
  def ticket_status_badge_class(status_title)
    case status_title.to_s.downcase
    when "aberto"
      "text-bg-warning"
    when "em andamento"
      "text-bg-primary"
    when "aguardando informação", "aguardando informacao"
      "text-bg-secondary"
    when "fechado"
      "text-bg-success"
    else
      "text-bg-light border"
    end
  end
end
