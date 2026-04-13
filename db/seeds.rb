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
  { name: "Maria Santos", email: "maria@dunnas.com.br", scopes: [scopes[0]], password: "Dunnas@2024" },
  { name: "Carlos Oliveira", email: "carlos@dunnas.com.br", scopes: [scopes[1]], password: "Dunnas@2024" },
  { name: "Ana Costa", email: "ana@dunnas.com.br", scopes: [scopes[2], scopes[3]], password: "Dunnas@2024" }
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
    user.apartments = [all_apartments[residente_data[:apartment_index]]]
    user.save
  end
  user
end
puts "✓ #{residentes.count} residentes criados"
residentes.each do |r|
  apartments = r.apartments.map(&:identificator).join(", ").presence || "sem apartamento"
  puts "  - #{r.name} (#{apartments})"
end

puts "\n=== SEED CONCLUÍDO ==="
puts "\n📋 Resumo:"
puts "  ✓ Ticket Statuses: #{TicketStatus.count}"
puts "  ✓ Escopos: #{Scope.count}"
puts "  ✓ Tipos de Ticket: #{TicketType.count}"
puts "  ✓ Prédios: #{Building.count}"
puts "  ✓ Apartamentos: #{Apartment.count}"
puts "  ✓ Usuários: #{User.count} (1 admin, 3 colaboradores, #{residentes.count} residentes)"
puts "\n🔐 Credenciais de teste:"
puts "  Admin: admin@dunnas.com.br / Dunnas@2024"
puts "  Colaborador 1: maria@dunnas.com.br / Dunnas@2024"
puts "  Colaborador 2: carlos@dunnas.com.br / Dunnas@2024"
puts "  Colaborador 3: ana@dunnas.com.br / Dunnas@2024"
puts "  Residente 1: pedro@example.com / Residente@2024"
