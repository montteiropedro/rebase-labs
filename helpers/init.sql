CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS patients (
  id uuid DEFAULT uuid_generate_v4 (),
  cpf VARCHAR(11) NOT NULL PRIMARY KEY,
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  birthday VARCHAR NOT NULL,
  address VARCHAR NOT NULL,
  city VARCHAR NOT NULL,
  state VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS doctors (
  id uuid DEFAULT uuid_generate_v4 (),
  crm VARCHAR(10) NOT NULL PRIMARY KEY,
  crm_state VARCHAR(2) NOT NULL,
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS exams (
  id uuid DEFAULT uuid_generate_v4 (),
  patient_cpf VARCHAR(11) NOT NULL REFERENCES patients(cpf),
  doctor_crm VARCHAR(10) NOT NULL REFERENCES doctors(crm),
  token VARCHAR(6) NOT NULL UNIQUE PRIMARY KEY,
  date VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS exam_tests (
  id uuid DEFAULT uuid_generate_v4 (),
  exam_token VARCHAR(6) NOT NULL REFERENCES exams(token),
  type VARCHAR NOT NULL,
  type_limits VARCHAR NOT NULL,
  type_result VARCHAR NOT NULL,
  UNIQUE (exam_token, type)
);
