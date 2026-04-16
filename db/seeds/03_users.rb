# db/seeds/03_users.rb

# 1. ADMIN
User.create!(
  name: "João Silva Admin",
  email: "admin@dunnas.com.br",
  password: "Dunnas@2024",
  password_confirmation: "Dunnas@2024",
  user_type: :admin
)

# 2. COLABORADORES
scopes = Scope.all.to_a
5.times do |i|
  user = User.create!(
    name: "Colaborador Téc #{i+1}",
    email: "tec#{i+1}@dunnas.com.br",
    password: "Dunnas@2024",
    password_confirmation: "Dunnas@2024",
    user_type: :colaborator
  )
  user.scopes << scopes.sample(rand(1..2)) # Atribui 1 ou 2 escopos aleatórios
end

# 3. RESIDENTES (Gerador Nativo)
primeiros_nomes = %w[Lucas Juliana Gustavo Camila Ricardo Mariana Felipe Sophia Arthur Alice Bernardo Julia Heitor Laura Davi]
sobrenomes = %w[Silva Santos Oliveira Souza Rodrigues Ferreira Alves Pereira Lima Costa Gomes Martins Ribeiro Carvalho Almeida]

apartments = Apartment.all.to_a

# Criando 40 residentes aleatórios
40.times do |i|
  nome_completo = "#{primeiros_nomes.sample} #{sobrenomes.sample} #{sobrenomes.sample}"

  user = User.create!(
    name: nome_completo,
    email: "residente#{i+1}@example.com",
    password: "Residente@2024",
    password_confirmation: "Residente@2024",
    user_type: :resident
  )

  # Atribui um apartamento aleatório ao residente
  user.apartments << apartments.pop if apartments.any?
end

puts "  ✓ 1 Admin criado"
puts "  ✓ #{User.where(user_type: :colaborator).count} Colaboradores criados"
puts "  ✓ #{User.where(user_type: :resident).count} Residentes criados"
