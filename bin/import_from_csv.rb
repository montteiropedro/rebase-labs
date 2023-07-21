require 'csv'
require_relative '../helpers/db_helper.rb'

rows = CSV.read("./data.csv", col_sep: ';')
columns = rows.shift

data = rows.map do |row|
  row.each_with_object({}).with_index do |(cell, acc), idx|
    column = columns[idx]
    acc[column] = cell
  end
end

DB.create_tables
DB.insert_csv_data(data)
