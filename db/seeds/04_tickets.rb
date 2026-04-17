# db/seeds/04_tickets.rb

residentes = User.where(user_type: :resident).includes(:apartments).to_a
colaboradores = User.where(user_type: :colaborator).includes(:scopes).to_a
ticket_types = TicketType.all.to_a
statuses = TicketStatus.all.to_a

status_com_colaborador = [ "Em Andamento", "Resolvido", "Fechado" ]
status_finalizados = [ "Resolvido", "Fechado" ]

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

# Gerar 25 tickets aleatórios para testar paginação e relatórios
25.times do |i|
  residente = residentes.sample
  tipo = ticket_types.sample
  status = statuses.sample
  colaboradores_compativeis = colaboradores.select { |colaborador| colaborador.scope_ids.include?(tipo.scope_id) }

  # Só atribui colaborador quando houver escopo compatível com o tipo do ticket.
  colaborador_atribuido = nil
  if status_com_colaborador.include?(status.title)
    if colaboradores_compativeis.any?
      colaborador_atribuido = colaboradores_compativeis.sample
    else
      status_sem_colaborador = statuses.reject { |item| status_com_colaborador.include?(item.title) }
      status = status_sem_colaborador.sample if status_sem_colaborador.any?
    end
  elsif colaboradores_compativeis.any? && rand < 0.35
    colaborador_atribuido = colaboradores_compativeis.sample
  end

  # Datas retroativas para simular histórico (entre hoje e 60 dias atrás)
  data_criacao = rand(1..60).days.ago
  data_finalizacao = status_finalizados.include?(status.title) ? data_criacao + rand(1..5).days : nil

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
