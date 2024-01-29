require 'sinatra'
require 'sinatra/reloader'
require 'slim'

get('/') do
  slim(:start)
end
