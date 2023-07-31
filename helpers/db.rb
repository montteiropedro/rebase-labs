require 'pg'
require_relative 'formatter'

module DB
  if ENV['APP_ENV'] == 'test'
    HOST = 'db_test'
    USER = 'test'
    PASS = 'test'
  else
    HOST = 'db'
    USER = 'admin'
    PASS = 'admin'
  end

  def self.create_db_connection
    db = PG.connect(host: HOST, user: USER, password: PASS)
  end

  def self.create_tables(db)
    tables_count = db.exec("SELECT FROM pg_tables WHERE tablename IN ('patients', 'doctors', 'exams', 'exam_tests');").num_tuples

    return if tables_count == 4

    db.exec("CREATE TABLE IF NOT EXISTS patients (id uuid DEFAULT uuid_generate_v4 (),
                                                  cpf VARCHAR(11) NOT NULL PRIMARY KEY,
                                                  name VARCHAR NOT NULL,
                                                  email VARCHAR NOT NULL,
                                                  birthday VARCHAR NOT NULL,
                                                  address VARCHAR NOT NULL,
                                                  city VARCHAR NOT NULL,
                                                  state VARCHAR NOT NULL)")

    db.exec("CREATE TABLE IF NOT EXISTS doctors (id uuid DEFAULT uuid_generate_v4 (),
                                                crm VARCHAR(10) NOT NULL PRIMARY KEY,
                                                crm_state VARCHAR(2) NOT NULL,
                                                name VARCHAR NOT NULL,
                                                email VARCHAR NOT NULL UNIQUE)")

    db.exec("CREATE TABLE IF NOT EXISTS exams (id uuid DEFAULT uuid_generate_v4 (),
                                              patient_cpf VARCHAR(11) NOT NULL REFERENCES patients(cpf),
                                              doctor_crm VARCHAR(10) NOT NULL REFERENCES doctors(crm),
                                              token VARCHAR(6) NOT NULL UNIQUE PRIMARY KEY,
                                              date VARCHAR NOT NULL)")

    db.exec("CREATE TABLE IF NOT EXISTS exam_tests (id uuid DEFAULT uuid_generate_v4 (),
                                                    exam_token VARCHAR(6) NOT NULL REFERENCES exams(token),
                                                    type VARCHAR NOT NULL,
                                                    type_limits VARCHAR NOT NULL,
                                                    type_result VARCHAR NOT NULL,
                                                    UNIQUE (exam_token, type))")
  end

  def self.reset_tables
    db = create_db_connection

    db.exec("DELETE FROM exam_tests;")
    db.exec("DELETE FROM exams;")
    db.exec("DELETE FROM patients;")
    db.exec("DELETE FROM doctors;")
  rescue
    puts e
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
      db.exec(
        "INSERT INTO exams (patient_cpf, doctor_crm, token, date) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING;",
        [d['cpf'].gsub(/[\-\.]/, ''), d['crm médico'], d['token resultado exame'], d['data exame']]
      )

    rescue => e
      puts e
    end
  end

  def self.insert_exam_tests(db, data)
    data.each do |d|
      db.exec(
        "INSERT INTO exam_tests (exam_token, type, type_limits, type_result) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING;",
        [d['token resultado exame'], d['tipo exame'], d['limites tipo exame'], d['resultado tipo exame']]
      )
    rescue => e
      puts e
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
    
    insert_patients(db, data)
    insert_doctors(db, data)
    insert_exams(db, data)
    insert_exam_tests(db, data)
  end
end
