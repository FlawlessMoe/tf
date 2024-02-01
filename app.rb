require 'sinatra'
require 'sinatra/reloader'
require 'slim'

get('/') do
  slim(:start)
end

get('/sign-n') do
  slim(:signin)
end

get('/dashboard') do
  slim(:dashboard)
end

get('/sign-p') do
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

get('/loggedin') do
  slim(:loggedin)
end
