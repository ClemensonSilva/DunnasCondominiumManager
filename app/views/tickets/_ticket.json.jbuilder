json.extract! ticket, :id, :user_id, :apartment_id, :ticket_status_id, :ticket_type_id, :title, :description, :attachments, :finished_at, :created_at, :updated_at
json.url ticket_url(ticket, format: :json)
