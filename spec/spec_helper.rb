require 'rspec'
require 'rack/test'
require_relative '../helpers/db'

DB.prepare_test_db

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  
  conf.formatter = :documentation
  conf.before(type: :system) do
    drive_by :rack_test
  end
end
