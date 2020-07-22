User.create(name: "管理者",
            email: "email@sample.com",
            password: "password",
            password_confirmation: "password",
            admin: true)
4.times do |n|
  name = Faker::Japanese::Name.name
  email = "email#{n+1}@sample.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password, 
               password_confirmation: password,
               superior: true)
end


59.times do |n|
  name = Faker::Japanese::Name.name
  email = "email#{n+5}@sample.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end