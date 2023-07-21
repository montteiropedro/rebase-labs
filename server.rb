require 'sinatra'
require 'rack/handler/puma'
require './helpers.rb'

get '/tests' do
  content_type :json
  Helpers::DB::Feature1.unformatted_json_data
end

get '/exames' do
  content_type :json
  Helpers::DB::Feature2.formatted_json_data
end

Rack::Handler::Puma.run(
  Sinatra::Application,
  Port: 3000,
  Host: '0.0.0.0'
)
