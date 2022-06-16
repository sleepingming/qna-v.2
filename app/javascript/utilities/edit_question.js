document.addEventListener('turbolinks:load', function() {
    const question = document.querySelector('.question')
    if (question) {
        question.addEventListener('click', editQuestionLinkHandler)
    }
})

function editQuestionLinkHandler(event) {
    const link = document.querySelector('.edit-question-link')
    if (event.target == link) {
        event.preventDefault();
        link.classList.add('hidden');
        document.getElementById('edit-question').classList.remove('hidden')
    }
}
