# Seed do Dunnas Condominium Manager
# Execute com: bin/rails db:seed

# Limpar dados existentes (opcional, descomentar se necessário)
# [TicketStatus, TicketType, Scope, Ticket, Comment, User, Apartment, Building].each(&:delete_all)

puts "=== Criando Ticket Statuses ==="
statuses = [
  { title: "Aberto", is_default: true },
  { title: "Em Andamento", is_default: false },
  { title: "Aguardando Informação", is_default: false },
  { title: "Fechado", is_default: false }
]

statuses.each do |status_data|
  TicketStatus.find_or_create_by!(title: status_data[:title]) do |status|
    status.is_default = status_data[:is_default]
  end
end
puts "✓ #{TicketStatus.count} status de tickets criados"

puts "\n=== Criando Escopos de Atuação ==="
scopes_data = [
  { title: "Limpeza e Higiene" },
  { title: "Manutenção Predial" },
  { title: "Paisagismo e Jardinagem" },
  { title: "Segurança" }
]

scopes = scopes_data.map { |scope_data| Scope.find_or_create_by!(title: scope_data[:title]) }
puts "✓ #{scopes.count} escopos de atuação criados"

puts "\n=== Criando Tipos de Ticket ==="
ticket_types_data = [
  { scope: scopes[0], title: "Limpeza de Área Comum", sla_hours: 24 },
  { scope: scopes[0], title: "Desentupimento", sla_hours: 48 },
  { scope: scopes[1], title: "Reparo Hidráulico", sla_hours: 48 },
  { scope: scopes[1], title: "Manutenção Elétrica", sla_hours: 24 },
  { scope: scopes[1], title: "Reparo de Vidro", sla_hours: 72 },
  { scope: scopes[2], title: "Poda de Árvores", sla_hours: 120 },
  { scope: scopes[2], title: "Limpeza de Área Verde", sla_hours: 96 },
  { scope: scopes[3], title: "Reporte de Incidente", sla_hours: 12 }
]

ticket_types_data.each do |tt_data|
  TicketType.find_or_create_by!(
    scope: tt_data[:scope],
    title: tt_data[:title]
  ) do |tt|
    tt.sla_hours = tt_data[:sla_hours]
  end
end
puts "✓ #{TicketType.count} tipos de ticket criados"

puts "\n=== Criando Prédios ==="
buildings_data = [
  { name: "Edifício Dunnas I", number_of_floors: 5, apartments_per_floor: 3 },
  { name: "Edifício Dunnas II", number_of_floors: 4, apartments_per_floor: 4 }
]

buildings = buildings_data.map do |building_data|
  Building.find_or_create_by!(name: building_data[:name]) do |b|
    b.number_of_floors = building_data[:number_of_floors]
    b.apartments_per_floor = building_data[:apartments_per_floor]
  end
end
puts "✓ #{buildings.count} prédios criados (#{Apartment.count} apartamentos gerados automaticamente)"

puts "\n=== Criando Usuários ==="

# Admin
admin = User.find_or_create_by!(email: "admin@dunnas.com.br") do |user|
  user.name = "João Silva"
  user.password = "Dunnas@2024"
  user.password_confirmation = "Dunnas@2024"
  user.user_type = :admin
end
puts "✓ Admin: #{admin.name} (#{admin.email})"

# Colaboradores
colaboradores_data = [
  { name: "Maria Santos", email: "maria@dunnas.com.br", scopes: [ scopes[0] ], password: "Dunnas@2024" },
  { name: "Carlos Oliveira", email: "carlos@dunnas.com.br", scopes: [ scopes[1] ], password: "Dunnas@2024" },
  { name: "Ana Costa", email: "ana@dunnas.com.br", scopes: [ scopes[2], scopes[3] ], password: "Dunnas@2024" }
]

colaboradores = colaboradores_data.map do |colaborador_data|
  user = User.find_or_create_by!(email: colaborador_data[:email]) do |u|
    u.name = colaborador_data[:name]
    u.password = colaborador_data[:password]
    u.password_confirmation = colaborador_data[:password]
    u.user_type = :colaborator
  end

  # Vincular escopos
  user.scopes = colaborador_data[:scopes]
  user.save
  user
end
puts "✓ #{colaboradores.count} colaboradores criados"
colaboradores.each { |c| puts "  - #{c.name} (#{c.scopes.map(&:title).join(', ')})" }

# Residentes
residentes_data = [
  { name: "Pedro Mendes", email: "pedro@example.com", apartment_index: 0 },
  { name: "Fernanda Gomes", email: "fernanda@example.com", apartment_index: 1 },
  { name: "Roberto Alves", email: "roberto@example.com", apartment_index: 2 },
  { name: "Beatriz Lima", email: "beatriz@example.com", apartment_index: 3 }
]

all_apartments = Apartment.all

residentes = residentes_data.map do |residente_data|
  user = User.find_or_create_by!(email: residente_data[:email]) do |u|
    u.name = residente_data[:name]
    u.password = "Residente@2024"
    u.password_confirmation = "Residente@2024"
    u.user_type = :resident
  end

  # Vincular apartamento (se existir)
  if residente_data[:apartment_index] < all_apartments.size
    user.apartments = [ all_apartments[residente_data[:apartment_index]] ]
    user.save
  end
  user
end
puts "✓ #{residentes.count} residentes criados"
residentes.each do |r|
  apartments = r.apartments.map(&:identificator).join(", ").presence || "sem apartamento"
  puts "  - #{r.name} (#{apartments})"
end

puts "\n=== Vinculando Moradores em Múltiplas Unidades ==="
if all_apartments.size >= 8
  moradores_multiplas_unidades = [
    [ residentes[0], [ all_apartments[0], all_apartments[4] ] ],
    [ residentes[1], [ all_apartments[1], all_apartments[5] ] ]
  ]

  moradores_multiplas_unidades.each do |residente, apartamentos|
    next unless residente

    residente.apartments = apartamentos.compact
    residente.save!
  end

  puts "✓ Moradores vinculados em múltiplas unidades"
end

puts "\n=== Criando Tickets de Exemplo ==="
statuses_by_title = TicketStatus.all.index_by(&:title)
ticket_types_by_title = TicketType.all.index_by(&:title)
default_status = TicketStatus.find_by(is_default: true) || statuses_by_title["Aberto"]

colaborador_por_scope = colaboradores.each_with_object({}) do |colaborador, mapa|
  colaborador.scopes.each do |scope|
    mapa[scope.id] ||= colaborador
  end
end

tickets_data = [
  {
    title: "[Seed] Vazamento na pia da cozinha",
    description: "A pia da cozinha está vazando desde ontem à noite.",
    apartment: residentes[0]&.apartments&.first,
    user: residentes[0],
    ticket_type: ticket_types_by_title["Reparo Hidráulico"],
    status: statuses_by_title["Aberto"] || default_status,
    created_at: 4.days.ago,
    finished_at: nil,
    attachments: "foto_vazamento_01.jpg"
  },
  {
    title: "[Seed] Lâmpada do corredor queimada",
    description: "Corredor do 3º andar sem iluminação desde a madrugada.",
    apartment: residentes[1]&.apartments&.first,
    user: residentes[1],
    ticket_type: ticket_types_by_title["Manutenção Elétrica"],
    status: statuses_by_title["Em Andamento"],
    created_at: 2.days.ago,
    finished_at: nil,
    attachments: ""
  },
  {
    title: "[Seed] Solicitação de poda no jardim lateral",
    description: "Árvore muito próxima da janela do apartamento.",
    apartment: residentes[2]&.apartments&.first,
    user: residentes[2],
    ticket_type: ticket_types_by_title["Poda de Árvores"],
    status: statuses_by_title["Aguardando Informação"],
    created_at: 3.days.ago,
    finished_at: nil,
    attachments: "https://example.com/foto-arvore.jpg"
  },
  {
    title: "[Seed] Limpeza de área comum do térreo",
    description: "Acúmulo de sujeira próximo aos elevadores.",
    apartment: residentes[3]&.apartments&.first,
    user: residentes[3],
    ticket_type: ticket_types_by_title["Limpeza de Área Comum"],
    status: statuses_by_title["Fechado"],
    created_at: 5.days.ago,
    finished_at: 1.day.ago,
    attachments: nil
  },
  {
    title: "[Seed] Incidente no portão de acesso",
    description: "Portão principal travando ao abrir remotamente.",
    apartment: residentes[0]&.apartments&.last,
    user: residentes[0],
    ticket_type: ticket_types_by_title["Reporte de Incidente"],
    status: statuses_by_title["Em Andamento"],
    created_at: 18.hours.ago,
    finished_at: nil,
    attachments: "video_portao.mp4"
  },
  {
    title: "[Seed] Entupimento no banheiro social",
    description: "Ralo sem escoamento e retorno de água.",
    apartment: residentes[1]&.apartments&.last,
    user: residentes[1],
    ticket_type: ticket_types_by_title["Desentupimento"],
    status: statuses_by_title["Aberto"] || default_status,
    created_at: 72.hours.ago,
    finished_at: nil,
    attachments: ""
  }
]

seed_tickets = []

tickets_data.each do |data|
  next unless data[:apartment] && data[:user] && data[:ticket_type] && data[:status]

  collaborator = colaborador_por_scope[data[:ticket_type].scope_id]

  ticket = Ticket.find_or_initialize_by(title: data[:title])
  ticket.assign_attributes(
    description: data[:description],
    apartment: data[:apartment],
    user: data[:user],
    collaborator: collaborator,
    ticket_type: data[:ticket_type],
    ticket_status: data[:status],
    finished_at: data[:finished_at],
    attachments: data[:attachments]
  )
  ticket.save!

  ticket.update_columns(
    created_at: data[:created_at],
    updated_at: [ data[:created_at] + 2.hours, Time.current ].min,
    finished_at: data[:finished_at]
  )

  seed_tickets << ticket
end

puts "✓ #{seed_tickets.count} tickets de exemplo criados/atualizados"

puts "\n=== Criando Comentários de Exemplo ==="
comentarios_data = [
  { ticket_title: "[Seed] Vazamento na pia da cozinha", user: residentes[0], content: "Abri o chamado porque o vazamento aumentou hoje cedo." },
  { ticket_title: "[Seed] Vazamento na pia da cozinha", user: colaboradores[1], content: "Equipe hidráulica agendada para inspeção amanhã às 09h." },
  { ticket_title: "[Seed] Lâmpada do corredor queimada", user: colaboradores[1], content: "Material separado. Troca será feita ainda hoje." },
  { ticket_title: "[Seed] Solicitação de poda no jardim lateral", user: colaboradores[2], content: "Pode enviar uma foto mais próxima dos galhos?" },
  { ticket_title: "[Seed] Limpeza de área comum do térreo", user: admin, content: "Serviço concluído e validado pela administração." },
  { ticket_title: "[Seed] Incidente no portão de acesso", user: colaboradores[2], content: "Ocorrência encaminhada para empresa de segurança." }
]

comentarios_criados = 0
comentarios_data.each do |dados|
  ticket = seed_tickets.find { |t| t.title == dados[:ticket_title] }
  next unless ticket && dados[:user]

  comment = Comment.find_or_initialize_by(ticket: ticket, user: dados[:user], content: dados[:content])
  if comment.new_record?
    comment.save!
    comentarios_criados += 1
  end
end

puts "✓ #{comentarios_criados} comentários de exemplo criados"

puts "\n=== SEED CONCLUÍDO ==="
puts "\n📋 Resumo:"
puts "  ✓ Ticket Statuses: #{TicketStatus.count}"
puts "  ✓ Escopos: #{Scope.count}"
puts "  ✓ Tipos de Ticket: #{TicketType.count}"
puts "  ✓ Prédios: #{Building.count}"
puts "  ✓ Apartamentos: #{Apartment.count}"
puts "  ✓ Usuários: #{User.count} (1 admin, 3 colaboradores, #{residentes.count} residentes)"
puts "  ✓ Tickets: #{Ticket.count}"
puts "  ✓ Comentários: #{Comment.count}"
puts "\n🔐 Credenciais de teste:"
puts "  Admin: admin@dunnas.com.br / Dunnas@2024"
puts "  Colaborador 1: maria@dunnas.com.br / Dunnas@2024"
puts "  Colaborador 2: carlos@dunnas.com.br / Dunnas@2024"
puts "  Colaborador 3: ana@dunnas.com.br / Dunnas@2024"
puts "  Residente 1: pedro@example.com / Residente@2024"
