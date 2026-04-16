# db/seeds.rb
puts "Iniciando o carregamento dos seeds..."

# Trava de seguraça: Evita apagar a produção por acidente
if Rails.env.development? || ENV['FORCE_SEED'] == 'true'
  puts "🧹 Limpando dados operacionais anteriores..."
  [ Comment, Ticket, User, Apartment, Building ].each(&:delete_all)
  # Não deletamos Status, Scope e TicketType aqui, pois eles usarão find_or_create_by
else
  puts "⚠️  ATENÇÃO: Você não está no ambiente de desenvolvimento."
  puts "Para rodar os seeds, use: FORCE_SEED=true bin/rails db:seed"
  exit
end

# Carrega todos os arquivos da pasta db/seeds em ordem alfabética
Dir[Rails.root.join('db', 'seeds', '*.rb')].sort.each do |file|
  puts "\n▶️  Carregando #{File.basename(file)}..."
  require file
end

puts "\n✅ SEED CONCLUÍDO COM SUCESSO!"
