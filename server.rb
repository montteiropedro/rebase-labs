require 'sinatra'
require 'rack/handler/puma'
require './helpers/exams.rb'

get '/tests' do
  content_type :json
  Exams::Feature1.all
end

get '/exams/json' do
  content_type :json
  Exams::Feature2.all
end

get '/exams' do
  content_type :html
  File.open('index.html')
end

get '/exams/:token' do
  content_type :json
  Exams::Feature2.find(params[:token])
end

Rack::Handler::Puma.run(
  Sinatra::Application,
  Port: 3000,
  Host: '0.0.0.0'
)
