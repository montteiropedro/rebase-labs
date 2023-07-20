require 'csv'
require './helpers.rb'

rows = CSV.read("./data.csv", col_sep: ';')
columns = rows.shift

data = rows.map do |row|
  row.each_with_object({}).with_index do |(cell, acc), idx|
    column = columns[idx]
    acc[column] = cell
  end
end

Helpers::DB.create_tables
Helpers::DB.insert_csv_data(data)
