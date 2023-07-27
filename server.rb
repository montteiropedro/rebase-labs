require 'sinatra'
require 'redis'
require 'csv'
require 'rack/handler/puma'
require_relative './helpers/exams'
require_relative './helpers/import'
require_relative './helpers/db'

post '/import' do
  raw = CSV.read(params[:data][:tempfile]).flatten.join("\n");
  ExamsImporter.perform_async(raw)
end

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
