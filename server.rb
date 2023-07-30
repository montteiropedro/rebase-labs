require 'sinatra'
require 'sinatra/namespace'
require 'redis'
require 'csv'
require 'rack/handler/puma'
require_relative './helpers/exams'
require_relative './helpers/import'
require_relative './helpers/db'

get '/' do
  redirect '/exams'
end

get '/exams' do
  content_type :html
  File.open('index.html')
end

get '/reset' do
  DB.reset_tables
  redirect "/exams"
end

namespace '/api' do
  post '/v1/import' do
    content_type :json

    begin
      raw = CSV.read(params[:data][:tempfile]).flatten.join("\n");
      ExamsImporter.perform_async(raw)
      body({ message: 'CSV received successfully' }).to_json
    rescue
      status 400
      body({
        error: 'Invalid file type',
        permitted_file_type: 'text/csv',
        received_file_type: params[:data][:type]
      }).to_json
    end
  end

  get '/v1/exams' do
    content_type :json
    Exams::V1.all.to_json
  end
  
  get '/v2/exams' do
    content_type :json
    Exams::V2.all.to_json
  end
  
  get '/v2/exams/:token' do
    content_type :json
    data = Exams::V2.find(params[:token])
  
    status 404 if data.empty?
    data.to_json
  end
end

if ENV['APP_ENV'] != 'test'
  Rack::Handler::Puma.run(
    Sinatra::Application,
    Port: 3000,
    Host: '0.0.0.0'
  )
end
