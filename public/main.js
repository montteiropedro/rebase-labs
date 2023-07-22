const fragment = new DocumentFragment();
const url = 'http://localhost:3000/exams/json';

function setResultColor(result, minLimit, maxLimit) {
  if (Number(result) >= Number(minLimit) && Number(result) <= Number(maxLimit)) return 'test-result-neutral';
  if (Number(result) < Number(minLimit)) return 'test-result-good';
  if (Number(result) > Number(maxLimit)) return 'test-result-danger';
}

fetch(url)
  .then((res) => res.json())
  .then((data) => {
    data.forEach((exam) => {
      const examDiv = document.createElement('div');

      examDiv.innerHTML = `
        <div class="exam-card--header">
          <i id="exam-card--btn" class="fa-solid fa-chevron-down"></i>

          <div>
            <span class="exam-card--title">Exame</span>
            <span class="exam-card--text">${exam.result_token}</span>
          </div>

          <div>
            <span class="exam-card--title">CPF do paciente</span>
            <span class="exam-card--text">${exam.cpf}</span>
          </div>

          <span class="exam-card--text">${new Date(exam.result_date).toLocaleDateString('pt-BR', { timeZone: 'UTC' })}</span>
        </div>

        <div class="exam-card--body hidden"></div>
      `;

      const patientTable = document.createElement('table');
      patientTable.innerHTML = `
        <thead>
          <tr>
            <th>Paciente</th>
            <th>Data de nascimento</th>
            <th>E-mail</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>${exam.name}</td>
            <td>${new Date(exam.birthday).toLocaleDateString('pt-BR', { timeZone: 'UTC' })}</td>
            <td>${exam.email}</td>
          </tr>
        </tbody>
      `;

      const doctorTable = document.createElement('table');
      doctorTable.innerHTML = `
        <thead>
          <tr>
            <th>Médico(a)</th>
            <th>CRM</th>
            <th>Estado do CRM</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>${exam.doctor.name}</td>
            <td>${exam.doctor.crm}</td>
            <td>${exam.doctor.crm_state}</td>
          </tr>
        </tbody>
      `;

      const testsTable = document.createElement('table');
      testsTable.innerHTML = `
        <thead>
          <tr>
            <th>Tipo</th>
            <th>Limites</th>
            <th>Resultado</th>
          </tr>
        </thead>
        <tbody></tbody>
      `;

      exam.tests.forEach((test) => {
        const limits = test.limits.match(/\d+/g);
        const tr = document.createElement('tr');

        tr.innerHTML = `
          <td>${test.type}</td>
          <td>${test.limits}</td>
          <td class="${setResultColor(test.result, limits[0], limits[1])}">${test.result}</td>
        `;

        testsTable.children[1].appendChild(tr);
      });

      fragment.appendChild(examDiv).classList.add('exam-card');
      examDiv.children[1].appendChild(patientTable);
      examDiv.children[1].appendChild(doctorTable);
      examDiv.children[1].appendChild(testsTable);
    })
  })
  .then(() => {
    document.querySelector('section#exams').appendChild(fragment)

    document.querySelectorAll('i#exam-card--btn').forEach(button => {
      button.addEventListener('click', () => {
        button.classList.toggle('active');
        button.parentElement.nextElementSibling.classList.toggle('visible');
      });
    });
  })
  .catch((error) => console.log(error));
