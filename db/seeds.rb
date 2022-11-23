# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(name: "Marc Depauw", login: "marc", password: "123", password_confirmation: "123", email: "marc@emday.be")

Permission.create(key: "show_asset", category: "Assets")
Permission.create(key: "update_asset", category: "Assets")
Permission.create(key: "destroy_asset", category: "Assets")
Permission.create(key: "show_import_session", category: "Imports")
Permission.create(key: "create_import_session", category: "Imports")
Permission.create(key: "destroy_import_session", category: "Imports")
Permission.create(key: "show_user", category: "Users")
Permission.create(key: "create_user", category: "Users")
Permission.create(key: "update_user", category: "Users")
Permission.create(key: "destroy_user", category: "Users")
