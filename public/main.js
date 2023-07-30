const fragment = new DocumentFragment();

document.querySelector('#csv-import-form > input').onchange = (e) => {
  document.querySelector('#csv-import-form > label > span').textContent = e.target.files[0].name;
}

document.querySelector('#csv-import-form').onsubmit = (e) => {
  e.preventDefault();

  const formData = new FormData();
  formData.append('data', e.target.data.files[0]);

  fetch('http://localhost:3000/api/v1/import', {
    method: 'POST',
    body: formData
  })
    .then(res => {
      if (res.ok) {
        console.log('CSV Data successfully loaded');
      } else {
        throw new Error('CSV Data load failed');
      }
    })
    .catch(error => console.error(error));
}


document.querySelector('.search-form').onsubmit = (e) => {
  e.preventDefault();
  const searchQuery = e.target.token.value;
  document.querySelector('section#exams').innerHTML = '';

  if (searchQuery !== '') {
    fetchData(`http://localhost:3000/api/v2/exams/${searchQuery}`);
  } else {
    fetchData();
  }
};

function setResultStyle(result, minLimit, maxLimit) {
  if (Number(result) >= Number(minLimit) && Number(result) <= Number(maxLimit)) return { color: 'test-result-good', icon: 'check' };

  return { color: 'test-result-danger', icon: 'exclamation' };
}

function fetchData(url = 'http://localhost:3000/api/v2/exams') {
  fetch(url)
    .then((res) => res.json())
    .then((data) => {
      data.forEach((exam) => {
        const examDiv = document.createElement('div');

        examDiv.innerHTML = `
        <div class="exam-card--header">
          <i class="fa-solid fa-chevron-down exam-card--btn"></i>

          <div>
            <span class="exam-card--title">Exame</span>
            <span class="exam-card--text">${exam.result_token}</span>
          </div>

          <div>
            <span class="exam-card--title">CPF do paciente</span>
            <span class="exam-card--text">${exam.cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4")}</span>
          </div>

          <span class="exam-card--text">${new Date(exam.result_date).toLocaleDateString('pt-BR', { timeZone: 'UTC' })}</span>
        </div>

        <div class="exam-card--body"></div>
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
          const resultStyle = setResultStyle(test.result, limits[0], limits[1]);

          tr.innerHTML = `
          <td>${test.type}</td>
          <td>${test.limits}</td>
          <td class="${resultStyle.color} d-flex justify-content-between align-items-center">
            ${test.result}
            <i class="fa-solid fa-circle-${resultStyle.icon}"></i>
          </td>
        `;

          testsTable.children[1].appendChild(tr);
        });

        fragment.appendChild(examDiv).classList.add('exam-card');
        examDiv.children[1].appendChild(patientTable);
        examDiv.children[1].appendChild(doctorTable);
        examDiv.children[1].appendChild(testsTable);
      });

      document.querySelector('#results-count').textContent = `${data.length} Exames`;
    })
    .then(() => {
      document.querySelector('section#exams').appendChild(fragment);

      document.querySelectorAll('div.exam-card--header').forEach(cardHeader => {
        cardHeader.addEventListener('click', () => {
          cardHeader.children[0].classList.toggle('active');
          cardHeader.parentElement.children[1].classList.toggle('visible');
        });
      });
    })
    .catch((error) => console.error(error));
}

window.onload = () => fetchData();
