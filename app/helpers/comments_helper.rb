module CommentsHelper
  COMMENT_TIMELINE_PREVIEW_LIMIT = 33
  COMMENT_OWNER_ROLE_STYLES = {
    "resident" => "bg-success text-white",
    "colaborator" => "bg-warning text-dark",
    "admin" => "bg-primary text-white"
  }.freeze

  def comment_owner_name(comment)
    comment.user&.name.presence || comment.user&.email || "Usuario"
  end

  def comment_timeline_title(comment)
    "Interacao em #{l(comment.created_at, format: :short)}"
  end

  def comment_preview_text(comment, limit: COMMENT_TIMELINE_PREVIEW_LIMIT)
    return "" if comment.content.blank?

    content = comment.content.to_s.strip
    content.length > limit ? "#{content.first(limit)}..." : content
  end

  def comment_preview_truncated?(comment, limit: COMMENT_TIMELINE_PREVIEW_LIMIT)
    comment.content.to_s.strip.length > limit
  end

  def comment_owner_role_label(comment)
    case comment.user&.user_type
    when "resident"
      "Residente"
    when "colaborator"
      "Colaborador"
    when "admin"
      "Admin"
    else
      "Usuario"
    end
  end

  def comment_owner_role_badge_class(comment)
    base_classes = "badge rounded-pill fw-semibold"
    role_classes = COMMENT_OWNER_ROLE_STYLES.fetch(comment.user&.user_type.to_s, "bg-secondary text-white")

    "#{base_classes} #{role_classes}"
  end
end
