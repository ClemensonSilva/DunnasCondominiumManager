class BuildingStatistics
  def initialize(building)
    @building = building
  end
  def tickets_for_show
    @building.tickets
      .includes(:ticket_status, :ticket_type, :user, :apartment)
      .order(created_at: :desc)
  end

  def residents_count
    @building.apartments
      .joins(:users)
      .merge(User.residents)
      .distinct
      .count("users.id")
  end

  def total_apartments
    @building.apartments.count
  end

  def occupied_apartments_count
    @building.apartments
      .joins(:users)
      .merge(User.residents)
      .distinct
      .count
  end

  def occupancy_rate
    return 0 if total_apartments.zero?

    ((occupied_apartments_count.to_f / total_apartments) * 100).round(1)
  end

  def closed_tickets_count(tickets_relation = tickets_for_show)
    tickets_relation.where.not(finished_at: nil).count
  end

  def open_tickets_count(tickets_relation = tickets_for_show)
    tickets_relation.count - closed_tickets_count(tickets_relation)
  end

  def overdue_tickets_count(tickets_relation = tickets_for_show)
    tickets_relation
      .includes(:ticket_type)
      .where(finished_at: nil)
      .to_a
      .count do |ticket|
        sla_hours = ticket.ticket_type&.sla_hours.to_i
        sla_hours.positive? && (ticket.created_at + sla_hours.hours) < Time.current
      end
  end

  def average_resolution_hours(tickets_relation = tickets_for_show)
    finished_intervals = tickets_relation
      .where.not(finished_at: nil)
      .pluck(:created_at, :finished_at)

    return nil if finished_intervals.empty?

    total_seconds = finished_intervals.sum { |created_at, finished_at| finished_at - created_at }
    ((total_seconds / finished_intervals.size) / 3600.0).round(1)
  end

  def top_ticket_types(limit = 3, tickets_relation = tickets_for_show)
    tickets_relation
      .reorder(nil)
      .joins(:ticket_type)
      .group("ticket_types.title")
      .count
      .sort_by { |_title, total| -total }
      .first(limit)
      .to_h
  end

  def collaborator_activity(limit = 3, tickets_relation = tickets_for_show)
    by_collaborator_id = tickets_relation
      .reorder(nil)
      .where.not(collaborator_id: nil)
      .group(:collaborator_id)
      .count

    collaborator_names = User
      .where(id: by_collaborator_id.keys)
      .pluck(:id, :name)
      .to_h

    by_collaborator_id
      .map { |collaborator_id, total| [ collaborator_names[collaborator_id].presence || "Sem nome", total ] }
      .sort_by { |_name, total| -total }
      .first(limit)
      .to_h
  end

  def last_ticket_created_at(tickets_relation = tickets_for_show)
    tickets_relation.maximum(:created_at)
  end

  def last_ticket_updated_at(tickets_relation = tickets_for_show)
    tickets_relation.maximum(:updated_at)
  end
end
