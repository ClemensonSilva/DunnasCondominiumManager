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

  def page_header_button(label, path, ability:, subject:, options: {})
    return unless can?(ability, subject)

    link_to(label, path, **options)
  end
end
