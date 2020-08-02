User.create(name: "管理者",
            email: "email@sample.com",
            password: "password",
            password_confirmation: "password",
            admin: true,
            uid: "101",
            employee_number: "1001")
            
4.times do |n|
  name = Faker::Japanese::Name.name
  email = "email#{n+1}@sample.com"
  password = "password"
  uid = "#{n+102}"
  employee_number = "#{n+1002}"
  User.create!(name: name,
              email: email,
              password: password,
              password_confirmation: password,
              superior: true,
              uid: uid,
              employee_number: employee_number)
end


59.times do |n|
  name = Faker::Japanese::Name.name
  email = "email#{n+5}@sample.com"
  password = "password"
  uid = "#{n+106}"
  employee_number = "#{n+1006}"
  User.create!(name: name,
              email: email,
              password: password,
              password_confirmation: password,
              uid: uid,
              employee_number: employee_number)
end