2.times do |n|
  name = Faker::Japanese::Name.name
  email = "admin#{n+1}@sample.com"
  password = "password"
  uid = "#{n+101}"
  employee_number = "#{n+1001}"
  User.create!(name: name,
              email: email,
              password: password,
              password_confirmation: password,
              admin: true,
              uid: uid,
              employee_number: employee_number)
end
            
2.times do |n|
  name = Faker::Japanese::Name.name
  email = "email#{n+1}@sample.com"
  password = "password"
  uid = "#{n+103}"
  employee_number = "#{n+1003}"
  User.create!(name: name,
              email: email,
              password: password,
              password_confirmation: password,
              superior: true,
              uid: uid,
              employee_number: employee_number)
end


2.times do |n|
  name = Faker::Japanese::Name.name
  email = "email#{n+3}@sample.com"
  password = "password"
  uid = "#{n+105}"
  employee_number = "#{n+1005}"
  User.create!(name: name,
              email: email,
              password: password,
              password_confirmation: password,
              uid: uid,
              employee_number: employee_number)
end