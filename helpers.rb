require 'pg'
require 'date'

module Helpers
  module DB
    HOST = 'postgresdb'
    USER = 'admin'
    PASS = 'admin'
  
    def self.create_tables
      db = PG.connect(host: HOST, user: USER, password: PASS)
  
      db.exec("CREATE TABLE IF NOT EXISTS patients (id SERIAL,
                                                    cpf VARCHAR(11) NOT NULL UNIQUE PRIMARY KEY,
                                                    name VARCHAR NOT NULL,
                                                    email VARCHAR NOT NULL UNIQUE,
                                                    birthday VARCHAR NOT NULL,
                                                    address VARCHAR NOT NULL,
                                                    city VARCHAR NOT NULL,
                                                    state VARCHAR NOT NULL)")
  
      db.exec("CREATE TABLE IF NOT EXISTS doctors (id SERIAL,
                                                  crm VARCHAR(10) NOT NULL UNIQUE PRIMARY KEY,
                                                  crm_state VARCHAR(2) NOT NULL,
                                                  name VARCHAR NOT NULL,
                                                  email VARCHAR NOT NULL UNIQUE)")
  
      db.exec("CREATE TABLE IF NOT EXISTS exams (id SERIAL,
                                                patient_cpf VARCHAR(11) NOT NULL REFERENCES patients(cpf),
                                                doctor_crm VARCHAR(10) NOT NULL REFERENCES doctors(crm),
                                                token VARCHAR(6) NOT NULL UNIQUE PRIMARY KEY,
                                                date VARCHAR NOT NULL)")

      db.exec("CREATE TABLE IF NOT EXISTS exam_tests (id SERIAL,
                                                      exam_token VARCHAR(6) NOT NULL REFERENCES exams(token),
                                                      type VARCHAR NOT NULL,
                                                      type_limits VARCHAR NOT NULL,
                                                      type_result VARCHAR NOT NULL)")
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
      exams = data.uniq { |obj| obj['token resultado exame'] }

      exams.each do |d|
        db.exec(
          "INSERT INTO exams (patient_cpf, doctor_crm, token, date)
          VALUES ($1, $2, $3, $4)",
          [d['cpf'].gsub(/[\-\.]/, ''), d['crm médico'], d['token resultado exame'], d['data exame']]
        )
      end
    end

    def self.insert_exam_tests(db, data)
      data.each do |d|
        db.exec(
          "INSERT INTO exam_tests (exam_token, type, type_limits, type_result) VALUES ($1, $2, $3, $4)",
          [d['token resultado exame'], d['tipo exame'], d['limites tipo exame'], d['resultado tipo exame']]
        )
      end
    end
  
    def self.insert_csv_data(csv_data)
      db = PG.connect(host: HOST, user: USER, password: PASS)
  
      insert_patients(db, csv_data)
      insert_doctors(db, csv_data)
      insert_exams(db, csv_data)
      insert_exam_tests(db, csv_data)
    end
  
    module Feature1
      def self.unformatted_json_data
        db = PG.connect(host: HOST, user: USER, password: PASS)
    
        data = db.exec('
          SELECT p.cpf, p.name AS "patient_name", p.email AS "patient_email", p.birthday AS "patient_birthday", p.address AS "patient_address", p.city AS "patient_city", p.state AS "patient_state",
                 d.crm AS "doctor_crm", d.crm_state AS "doctor_crm_state", d.name AS "doctor_name", d.email AS "doctor_email",
                 e.token AS "exam_result_token", e.date AS "exam_date",
                 et.type AS "exam_type", et.type_limits AS "limits_exam_type", et.type_result AS "result_exam_type"
          FROM exams AS e
          JOIN exam_tests AS et
            ON e.token = et.exam_token
          JOIN patients AS p
            ON e.patient_cpf = p.cpf
          JOIN doctors AS d
            ON e.doctor_crm = d.crm;
        ')
    
        data.to_a.to_json
      end
    end

    module Feature2
      def self.formatted_json_data
        db = PG.connect(host: HOST, user: USER, password: PASS)
    
        exam_data = db.exec('
          SELECT p.cpf, p.name AS "patient_name", p.email AS "patient_email", p.birthday AS "patient_birthday",
                 d.crm AS "doctor_crm", d.crm_state AS "doctor_crm_state", d.name AS "doctor_name", d.email AS "doctor_email",
                 e.token AS "exam_result_token", e.date AS "exam_date"
          FROM exams AS e
          JOIN patients AS p
            ON e.patient_cpf = p.cpf
          JOIN doctors AS d
            ON e.doctor_crm = d.crm;
        ')
    
        exam_data.map do |d|
          {
            cpf: d['cpf'],
            name: d['patient_name'],
            email: d['patient_email'],
            birthday: d['patient_birthday'],
            result_token: d['exam_result_token'],
            result_date: d['exam_date'],
            doctor: {
              crm: d['doctor_crm'],
              crm_state: d['doctor_crm_state'],
              name: d['doctor_name']
            },
            tests: db.exec(
              'SELECT type, type_limits AS "limits", type_result AS "result" FROM exam_tests WHERE exam_tests.exam_token = $1',
              [d['exam_result_token']]
            ).to_a
          }
        end.to_json
      end
    end
  end
end
