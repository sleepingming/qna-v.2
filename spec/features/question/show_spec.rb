require 'rails_helper'

feature 'User can see question and answers', "
  In order to find solution
  As an any user
  I'd like to see all answers
" do
  given(:answer) { create(:answer) }

  scenario 'sees the question and answers' do
    visit question_path(answer.question)
    expect(page).to have_content answer.question.title
    expect(page).to have_content answer.question.body
    expect(page).to have_content answer.body
  end
end
