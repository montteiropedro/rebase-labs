ENV['APP_ENV'] = 'test'

require_relative '../server'
require 'rspec'
require_relative 'spec_helper'

describe 'API de exames' do
  def app
    Sinatra::Application
  end

  after :each do
    DB.reset_tables
  end

  context 'GET /api/v2/exams' do
    it 'retorna todos os exames cadastrados (formatados de acordo com a Feature 2)' do
      data2_csv = CSV.read('./spec/support/data2.csv').flatten.join("\n")
      DB.insert_csv_data(data2_csv)
      get '/api/v2/exams'

      expect(last_response).to be_ok
      expect(last_response.content_type).to include 'application/json'
      response_body = JSON.parse(last_response.body)
      expect(response_body.size).to eq 2
      expect(response_body[0]['cpf']).to eq '20824295048'
      expect(response_body[0]['name']).to eq 'John Doe'
      expect(response_body[0]['email']).to eq 'john@email.com'
      expect(response_body[0]['birthday']).to eq '2001-03-11'
      expect(response_body[0]['result_token']).to eq 'TOKEN1'
      expect(response_body[0]['result_date']).to eq '2021-08-05'
      expect(response_body[0]['doctor']['crm']).to eq 'B000BJ21J4'
      expect(response_body[0]['doctor']['crm_state']).to eq 'PI'
      expect(response_body[0]['doctor']['name']).to eq 'Maria Luiza Pires'
      expect(response_body[0]['tests'][0]['type']).to eq 'hemácias'
      expect(response_body[0]['tests'][0]['limits']).to eq '45-52'
      expect(response_body[0]['tests'][0]['result']).to eq '97'
      expect(response_body[0]['tests'][1]['type']).to eq 'leucócitos'
      expect(response_body[0]['tests'][1]['limits']).to eq '9-61'
      expect(response_body[0]['tests'][1]['result']).to eq '89'
      expect(response_body[1]['cpf']).to eq '67011367020'
      expect(response_body[1]['result_token']).to eq 'TOKEN2'
      expect(response_body[1]['doctor']['crm']).to eq 'B0002IQM67'
      expect(response_body[1]['tests'].size).to eq 2
    end

    it 'retorna vazio quando não existem exames cadastrados' do
      get '/api/v2/exams'

      expect(last_response).to be_ok
      expect(last_response.content_type).to include 'application/json'
      response_body = JSON.parse(last_response.body)
      expect(response_body).to be_empty
    end
  end

  context 'GET /api/v2/exams/:token' do
    context 'quando é passado um token completo' do
      it 'retorna o exame vinculado ao token (formatados de acordo com a Feature 3)' do
        data2_csv = CSV.read('./spec/support/data2.csv').flatten.join("\n")
        DB.insert_csv_data(data2_csv)
        get '/api/v2/exams/TOKEN1'

        expect(last_response).to be_ok
        expect(last_response.content_type).to include 'application/json'
        response_body = JSON.parse(last_response.body)
        expect(response_body.size).to eq 1
        expect(response_body[0]['cpf']).to eq '20824295048'
        expect(response_body[0]['name']).to eq 'John Doe'
        expect(response_body[0]['email']).to eq 'john@email.com'
        expect(response_body[0]['birthday']).to eq '2001-03-11'
        expect(response_body[0]['result_token']).to eq 'TOKEN1'
        expect(response_body[0]['result_date']).to eq '2021-08-05'
        expect(response_body[0]['doctor']['crm']).to eq 'B000BJ21J4'
        expect(response_body[0]['doctor']['crm_state']).to eq 'PI'
        expect(response_body[0]['doctor']['name']).to eq 'Maria Luiza Pires'
        expect(response_body[0]['tests'][0]['type']).to eq 'hemácias'
        expect(response_body[0]['tests'][0]['limits']).to eq '45-52'
        expect(response_body[0]['tests'][0]['result']).to eq '97'
        expect(response_body[0]['tests'][1]['type']).to eq 'leucócitos'
        expect(response_body[0]['tests'][1]['limits']).to eq '9-61'
        expect(response_body[0]['tests'][1]['result']).to eq '89'
      end
  
      it 'retorna vazio quando o token não existe' do
        get '/api/v2/exams/TOKEN1'

        expect(last_response).to be_not_found
        expect(last_response.content_type).to include 'application/json'
        response_body = JSON.parse(last_response.body)
        expect(response_body).to be_empty
      end
    end

    context 'quando é passado apenas alguns caracteres do token' do
      it 'retorna todos exames que possuem aquela sequência de caracteres no seu token (formatados de acordo com a Feature 3)' do
        data3_csv = CSV.read('./spec/support/data3.csv').flatten.join("\n")
        DB.insert_csv_data(data3_csv)
        get '/api/v2/exams/TOK'

        expect(last_response).to be_ok
        expect(last_response.content_type).to include 'application/json'
        response_body = JSON.parse(last_response.body)
        expect(response_body.size).to eq 2
        expect(response_body[0]['cpf']).to eq '20824295048'
        expect(response_body[0]['result_token']).to eq 'TOKEN1'
        expect(response_body[0]['doctor']['crm']).to eq 'B000BJ21J4'
        expect(response_body[0]['tests'].size).to eq 2
        expect(response_body[1]['cpf']).to eq '67011367020'
        expect(response_body[1]['result_token']).to eq 'TOKEN2'
        expect(response_body[1]['doctor']['crm']).to eq 'B0002IQM67'
        expect(response_body[1]['tests'].size).to eq 2
      end

      it 'retorna vazio se nenhum exame possuir aquela sequência de caracteres no seu token' do
        data3_csv = CSV.read('./spec/support/data3.csv').flatten.join("\n")
        DB.insert_csv_data(data3_csv)
        get '/api/v2/exams/N0T'

        expect(last_response).to be_not_found
        expect(last_response.content_type).to include 'application/json'
        response_body = JSON.parse(last_response.body)
        expect(response_body.size).to eq 0
      end
    end
  end
end
