require_relative 'db_helper.rb'
require_relative 'formatter_helper.rb'

module Exams
  module Feature1
    def self.all
      db = DB::create_db_connection
  
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
    def self.all
      db = DB::create_db_connection
  
      exam_data = db.exec("
        SELECT p.cpf, p.name AS patient_name, p.email AS patient_email, p.birthday AS patient_birthday,
                d.crm AS doctor_crm, d.crm_state AS doctor_crm_state, d.name AS doctor_name, d.email AS doctor_email,
                e.token AS exam_result_token, e.date AS exam_date
        FROM exams AS e
        JOIN patients AS p
          ON e.patient_cpf = p.cpf
        JOIN doctors AS d
          ON e.doctor_crm = d.crm;
      ")
  
      exam_data.map { |d| Formatter::Feature2.data(db, d) }.to_json
    end
  
    def self.find(token)
      db = DB::create_db_connection
  
      exam_data = db.exec("
        SELECT p.cpf, p.name AS patient_name, p.email AS patient_email, p.birthday AS patient_birthday,
                d.crm AS doctor_crm, d.crm_state AS doctor_crm_state, d.name AS doctor_name, d.email AS doctor_email,
                e.token AS exam_result_token, e.date AS exam_date
        FROM exams AS e
        JOIN patients AS p
          ON e.patient_cpf = p.cpf
        JOIN doctors AS d
          ON e.doctor_crm = d.crm
        WHERE
          e.token ILIKE $1;
      ", ["%#{token}%"])
  
      exam_data.map { |d| Formatter::Feature2.data(db, d) }.to_json
    end
  end
end
