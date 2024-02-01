require 'sinatra'
require 'sinatra/reloader'
require 'slim'

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

get('/contactUs') do
  slim(:contactUs)
end

get('/aboutUs') do
  slim(:aboutUs)
end

get('/termsAndConditions') do
  slim(:termsAndConditions)
end
