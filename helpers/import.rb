require 'csv'
require 'sidekiq'
require_relative '../helpers/db'

class ExamsImporter
  include Sidekiq::Worker

  def perform(raw)
    DB.insert_csv_data(raw)
  end
end
