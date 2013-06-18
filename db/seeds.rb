# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html
puts 'ROLES'
YAML.load(ENV['roles']).each do |role|
  Role.find_or_create_by_name({ :name => role }, :without_protection => true)
  puts 'role: ' << role
end

unless ENV['admin_name'].nil? or ENV['admin_email'].nil? or ENV['admin_password'].nil?
  puts 'DEFAULT USERS'
  user = User.find_or_create_by_email :name => ENV['admin_name'].dup, :email => ENV['admin_email'].dup, :password => ENV['admin_password'].dup, :password_confirmation => ENV['admin_password'].dup
  puts 'user: ' << user.name
  user.add_role :admin
end
