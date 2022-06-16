document.addEventListener('turbolinks:load', function() {
    const answers = document.querySelector('.answers')
    if (answers) {
        answers.addEventListener('click', editAnswerLinkHandler)
    }
})

function editAnswerLinkHandler(event) {
    const count = document.querySelectorAll('.edit-answer-link')
    if (count.length) {
        for (let i = 0; i < count.length; i++) {
            if (count[i] == event.target) {
                event.preventDefault();
                count[i].classList.add('hidden');
                const answerId = count[i].dataset.answerId;
                document.getElementById('edit-answer-' + answerId).classList.remove('hidden');
            }
        }
    }
}
