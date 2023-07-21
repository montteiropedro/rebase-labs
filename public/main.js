const fragment = new DocumentFragment();
const url = 'http://localhost:3000/exams/json';

fetch(url)
  .then((res) => res.json())
  .then((data) => {
    data.forEach((exam) => {
      const li = document.createElement('li');
      li.textContent = `${exam.result_token}`;
      fragment.appendChild(li);
    })
  })
  .then(() => document.querySelector('ul').appendChild(fragment))
  .catch((error) => console.log(error));
