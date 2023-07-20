require 'pg'
require 'date'

module Helpers
  module DB
    HOST = 'postgresdb'
    USER = 'admin'
    PASS = 'admin'

    def self.create_db_connection
      PG.connect(host: HOST, user: USER, password: PASS)
    end
  
    def self.create_tables
      db = create_db_connection
  
      db.exec("CREATE TABLE IF NOT EXISTS patients (id SERIAL,
                                                     cpf VARCHAR(11) NOT NULL UNIQUE PRIMARY KEY,
                                                     name VARCHAR NOT NULL,
                                                     email VARCHAR NOT NULL UNIQUE,
                                                     birthday VARCHAR NOT NULL,
                                                     address VARCHAR NOT NULL,
                                                     city VARCHAR NOT NULL,
                                                     state VARCHAR NOT NULL)"
      )
  
      db.exec("CREATE TABLE IF NOT EXISTS doctors (id SERIAL,
                                                    crm VARCHAR(10) NOT NULL UNIQUE PRIMARY KEY,
                                                    crm_state VARCHAR(2) NOT NULL,
                                                    name VARCHAR NOT NULL,
                                                    email VARCHAR NOT NULL UNIQUE)"
      )
  
      db.exec("CREATE TABLE IF NOT EXISTS exams (id SERIAL,
                                                  patient_cpf VARCHAR(11) NOT NULL REFERENCES patients(cpf),
                                                  doctor_crm VARCHAR(10) NOT NULL REFERENCES doctors(crm),
                                                  result_token VARCHAR(6) NOT NULL,
                                                  date VARCHAR NOT NULL,
                                                  type VARCHAR NOT NULL,
                                                  type_limits VARCHAR NOT NULL,
                                                  result VARCHAR NOT NULL)"
      )
    end
  
    def self.insert_patients(db, data)
      patients = data.uniq { |obj| obj['cpf'] }
  
      patients.each do |d|
        db.exec(
          "INSERT INTO patients (cpf, name, email, birthday, address, city, state) VALUES ($1, $2, $3, $4, $5, $6, $7)",
          [d['cpf'].gsub(/[\-\.]/, ''), d['nome paciente'], d['email paciente'],
           d['data nascimento paciente'], d['endereço/rua paciente'], d['cidade paciente'], d['estado patiente']]
        )
      end
    end
  
    def self.insert_doctors(db, data)
      doctors = data.uniq { |obj| obj['crm médico'] }
  
      doctors.each do |d|
        db.exec(
          "INSERT INTO doctors (crm, crm_state, name, email) VALUES ($1, $2, $3, $4)",
          [d['crm médico'], d['crm médico estado'], d['nome médico'], d['email médico']]
        )
      end
    end
  
    def self.insert_exams(db, data)
      data.each do |d|
        db.exec(
          "INSERT INTO exams (patient_cpf, doctor_crm, result_token, date, type, type_limits, result)
          VALUES ($1, $2, $3, $4, $5, $6, $7)",
          [d['cpf'].gsub(/[\-\.]/, ''), d['crm médico'], d['token resultado exame'], d['data exame'],
           d['tipo exame'], d['limites tipo exame'], d['resultado tipo exame']]
        )
      end
    end
  
    def self.insert_csv_data(csv_data)
      db = create_db_connection
  
      insert_patients(db, csv_data)
      insert_doctors(db, csv_data)
      insert_exams(db, csv_data)
    end
  
    def self.get_json_data
      db = create_db_connection
  
      data = db.exec('
        SELECT p.cpf, p.name AS "patient_name", p.email AS "patient_email", p.birthday AS "patient_birthday", p.address AS "patient_address", p.city AS "patient_city", p.state AS "patient_state",
               d.crm AS "doctor_crm", d.crm_state AS "doctor_crm_state", d.name AS "doctor_name", d.email AS "doctor_email",
               e.result_token AS "exam_result_token", e.date AS "exam_date", e.type AS "exam_type", e.type_limits AS "limits_exam_type", e.result AS "result_exam_type"
        FROM exams AS e
        JOIN patients AS p
          ON e.patient_cpf = p.cpf
        JOIN doctors AS d
          ON e.doctor_crm = d.crm;
      ')
  
      data.to_a.to_json
    end
  end
end
