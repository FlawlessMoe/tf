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
