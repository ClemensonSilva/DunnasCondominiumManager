# db/seeds/04_tickets.rb

residentes = User.where(user_type: :resident).includes(:apartments).to_a
colaboradores = User.where(user_type: :colaborator).to_a
ticket_types = TicketType.all.to_a
statuses = TicketStatus.all.to_a

problemas_comuns = [
  "A torneira está pingando sem parar.",
  "Lâmpada do corredor queimou durante a madrugada.",
  "Gostaria de solicitar a poda da árvore que está batendo na janela.",
  "O portão da garagem demorou muito para fechar hoje cedo.",
  "Ralo do banheiro social está retornando água.",
  "Encontrei sujeira acumulada perto do elevador de serviço.",
  "A porta da entrada principal está rangendo muito.",
  "A energia oscilou e o disjuntor desarmou."
]

# Gerar 50 tickets aleatórios para testar paginação e relatórios
50.times do |i|
  residente = residentes.sample
  tipo = ticket_types.sample
  status = statuses.sample

  # Alguns tickets terão colaborador atribuído, outros não (dependendo do status)
  colaborador_atribuido = [ "Em Andamento", "Resolvido", "Fechado" ].include?(status.title) ? colaboradores.sample : nil

  # Datas retroativas para simular histórico (entre hoje e 60 dias atrás)
  data_criacao = rand(1..60).days.ago
  data_finalizacao = [ "Resolvido", "Fechado" ].include?(status.title) ? data_criacao + rand(1..5).days : nil

  ticket = Ticket.create!(
    title: "[#{(i+1).to_s.rjust(3, '0')}] #{tipo.title}",
    description: problemas_comuns.sample,
    user: residente,
    apartment: residente.apartments.first,
    ticket_type: tipo,
    ticket_status: status,
    collaborator: colaborador_atribuido,
    created_at: data_criacao,
    updated_at: data_criacao + rand(1..12).hours,
    finished_at: data_finalizacao
  )

  # Adicionar 1 a 3 comentários aleatórios em alguns tickets
  if rand(1..10) > 4 # 60% de chance de ter comentários
    rand(1..3).times do
      Comment.create!(
        ticket: ticket,
        user: [ residente, colaborador_atribuido ].compact.sample,
        content: [ "Ciente.", "Vou verificar amanhã cedo.", "Pode me enviar uma foto?", "Problema resolvido." ].sample,
        created_at: ticket.created_at + rand(1..24).hours
      )
    end
  end
end

puts "  ✓ #{Ticket.count} tickets de exemplo criados"
puts "  ✓ #{Comment.count} comentários gerados nas threads"
