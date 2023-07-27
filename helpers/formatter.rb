module Formatter
  module Feature2
    def self.data(db, data)
      {
        cpf: data['cpf'],
        name: data['patient_name'],
        email: data['patient_email'],
        birthday: data['patient_birthday'],
        result_token: data['exam_result_token'],
        result_date: data['exam_date'],
        doctor: {
          crm: data['doctor_crm'],
          crm_state: data['doctor_crm_state'],
          name: data['doctor_name']
        },
        tests: db.exec(
          'SELECT type, type_limits AS "limits", type_result AS "result" FROM exam_tests WHERE exam_tests.exam_token = $1',
          [data['exam_result_token']]
        ).to_a
      }
    end
  end
end
