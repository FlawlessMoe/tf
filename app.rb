require 'sinatra'
require 'slim'
require 'byebug'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
require 'sinatra/reloader'

# -----------------------------------

post('/users/') do
  username = params["username"]
  password = params["password"]
  register_user(username, password)
  redirect('/photos')
end

# -----------------------------------

get('/') do
  slim(:start)
end

get('/signin') do
  slim(:signin)
end

get('/dashboard') do
  slim(:dashboard)
end

get('/signup') do
  slim(:signup)
end

get('/accounts') do
  slim(:accounts)
end

get('/transactions') do
  slim(:transactions)
end

get('/onlineServices') do
  slim(:onlineServices)
end

get('/security') do
  slim(:security)
end

# -----------------------------------
