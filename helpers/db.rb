require 'pg'
require 'date'
require_relative 'formatter'

module DB
  HOST = 'db'
  USER = 'admin'
  PASS = 'admin'

  def self.create_db_connection
    PG.connect(host: HOST, user: USER, password: PASS)
  end

  def self.create_tables
    db = PG.connect(host: HOST, user: USER, password: PASS)

    db.exec("CREATE TABLE IF NOT EXISTS patients (id SERIAL,
                                                  cpf VARCHAR(11) NOT NULL PRIMARY KEY,
                                                  name VARCHAR NOT NULL,
                                                  email VARCHAR NOT NULL UNIQUE,
                                                  birthday VARCHAR NOT NULL,
                                                  address VARCHAR NOT NULL,
                                                  city VARCHAR NOT NULL,
                                                  state VARCHAR NOT NULL)")

    db.exec("CREATE TABLE IF NOT EXISTS doctors (id SERIAL,
                                                crm VARCHAR(10) NOT NULL PRIMARY KEY,
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
                                                    type_result VARCHAR NOT NULL,
                                                    UNIQUE (exam_token, type))")
  end

  def self.insert_patients(db, data)
    patients = data.uniq { |obj| obj['cpf'] }
    
    patients.each do |d|
      db.exec(
        "INSERT INTO patients (cpf, name, email, birthday, address, city, state) VALUES ($1, $2, $3, $4, $5, $6, $7) ON CONFLICT DO NOTHING;",
        [d['cpf'].gsub(/[\-\.]/, ''), d['nome paciente'], d['email paciente'],
        d['data nascimento paciente'], d['endereço/rua paciente'], d['cidade paciente'], d['estado patiente']]
      )
    end
  end

  def self.insert_doctors(db, data)
    doctors = data.uniq { |obj| obj['crm médico'] }

    doctors.each do |d|
      db.exec(
        "INSERT INTO doctors (crm, crm_state, name, email) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING;",
        [d['crm médico'], d['crm médico estado'], d['nome médico'], d['email médico']]
      )
    end
  end

  def self.insert_exams(db, data)
    exams = data.uniq { |obj| obj['token resultado exame'] }
    
    exams.each do |d|
      patient_exists = db.exec("SELECT cpf FROM patients WHERE cpf = $1", [d['cpf'].gsub(/[\-\.]/, '')]).to_a.any?
      doctor_exists = db.exec("SELECT crm FROM doctors WHERE crm = $1", [d['crm médico']]).to_a.any?

      next unless patient_exists && doctor_exists;

      db.exec(
        "INSERT INTO exams (patient_cpf, doctor_crm, token, date) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING;",
        [d['cpf'].gsub(/[\-\.]/, ''), d['crm médico'], d['token resultado exame'], d['data exame']]
      )
    end
  end

  def self.insert_exam_tests(db, data)
    data.each do |d|
      exam_exists = db.exec("SELECT token FROM exams WHERE token = $1", [d['token resultado exame']]).to_a.any?
      
      next unless exam_exists;

      db.exec(
        "INSERT INTO exam_tests (exam_token, type, type_limits, type_result) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING;",
        [d['token resultado exame'], d['tipo exame'], d['limites tipo exame'], d['resultado tipo exame']]
      )
    end
  end

  def self.insert_csv_data(csv_data)
    db = create_db_connection

    rows = CSV.parse(csv_data, col_sep: ';')
    columns = rows.shift
    
    data = rows.map do |row|
      row.each_with_object({}).with_index do |(cell, acc), idx|
        column = columns[idx]
        acc[column] = cell
      end
    end
    
    DB.create_tables

    insert_patients(db, data)
    insert_doctors(db, data)
    insert_exams(db, data)
    insert_exam_tests(db, data)
  end
end
