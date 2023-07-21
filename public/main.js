const fragment = new DocumentFragment();
const url = 'http://localhost:3000/exams/json';

fetch(url)
  .then((res) => res.json())
  .then((data) => {
    console.log(data[0]) // ! Remover depois - só pra visualizar no console.log a info

    data.forEach((exam) => {
      const examDiv = document.createElement('div');
      const testsUl = document.createElement('ul');

      // Cria o header do card do exame
      examDiv.innerHTML = `
        <div class="exam-card--header">
          <div>
            <span class="exam-card--title">Exame</span>
            <span class="exam-card--text">${exam.result_token}</span>
          </div>

          <div>
            <span class="exam-card--title">CPF do paciente</span>
            <span class="exam-card--text">${exam.cpf}</span>
          </div>

          <span class="exam-card--text">${exam.result_date}</span>
        </div>
      `;

      exam.tests.forEach((test) => {
        const li = document.createElement('li');

        li.textContent = `Tipo: ${test.type} | Limite: ${test.limits} | Resultado: ${test.result}`
        testsUl.appendChild(li);
      });

      fragment.appendChild(examDiv).classList.add('exam-card');
      examDiv.appendChild(testsUl);
    })
  })
  .then(() => document.querySelector('section#exams').appendChild(fragment))
  .catch((error) => console.log(error));
