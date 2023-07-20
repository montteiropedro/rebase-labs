require 'sinatra'
require 'rack/handler/puma'
require './helpers.rb'

get '/tests' do
  content_type :json
  Helpers::DB.get_json_data
end

# get '/tests' do
#   rows = CSV.read("./data.csv", col_sep: ';')

#   columns = rows.shift

#   rows.map do |row|
#     row.each_with_object({}).with_index do |(cell, acc), idx|
#       column = columns[idx]
#       acc[column] = cell
#     end
#   end.to_json
# end

Rack::Handler::Puma.run(
  Sinatra::Application,
  Port: 3000,
  Host: '0.0.0.0'
)
