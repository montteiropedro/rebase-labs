require 'csv'
require_relative '../helpers/import'

ExamsImporter.perform_async(File.read('./data.csv'))
