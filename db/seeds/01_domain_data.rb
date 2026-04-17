# db/seeds/01_domain_data.rb

puts "\n🎯 Criando Escopos de Atuação e Tipos de Tickets..."

# Mapeamento do Domínio: Escopo => [ Tipos de Ticket ]
domain_structure = {
  "Limpeza e Higiene" => [
    { title: "Limpeza de Área Comum", sla_hours: 24 },
    { title: "Limpeza de Corredores", sla_hours: 24 },
    { title: "Desentupimento", sla_hours: 48 }
  ],
  "Manutenção Predial" => [
    { title: "Problema na Pintura", sla_hours: 72 },
    { title: "Vazamento", sla_hours: 24 },
    { title: "Problema na Porta/Fechadura", sla_hours: 48 }
  ],
  "Paisagismo e Jardinagem" => [
    { title: "Poda de Árvores", sla_hours: 120 },
    { title: "Limpeza de Área Verde", sla_hours: 96 }
  ],
  "Segurança" => [
    { title: "Reporte de Incidente", sla_hours: 12 }
  ],
  "Elétrica" => [
    { title: "Problemas Elétricos", sla_hours: 24 },
    { title: "Problema de Iluminação Comum", sla_hours: 24 }
  ],
  "Hidráulica" => [
    { title: "Reparo Hidráulico", sla_hours: 48 },
    { title: "Reparos Hidráulicos Urgentes", sla_hours: 12 }
  ]
}

# Criação iterativa garantindo as associações e validações
domain_structure.each do |scope_title, ticket_types|
  # 1. Garante a existência do Escopo
  scope = Scope.find_or_create_by!(title: scope_title)

  # 2. Cria os Tipos de Ticket atrelados a este Escopo
  ticket_types.each do |tt_data|
    TicketType.find_or_create_by!(title: tt_data[:title], scope: scope) do |tt|
      tt.sla_hours = tt_data[:sla_hours]
    end
  end
end

puts "✓ #{Scope.count} escopos no banco."
puts "✓ #{TicketType.count} tipos de tickets configurados."
