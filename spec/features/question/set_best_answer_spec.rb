require 'rails_helper'

feature 'Author of question can set best answer', "
  In order to show which answer helped to solve the problem
  As an author of question
  I'd like to be able to set best answer
" do
  given(:question_author) { create(:user) }
  given(:not_author) { create(:user) }
  given(:question) { create(:question, user: question_author) }
  given!(:answer) { create(:answer, question: question, user: not_author) }
  given!(:same_answer) { create(:same_answer, question: question, user: question_author) }

  describe 'Authenticated user' do
    scenario 'author of question sets beat answer', js: true do
      sign_in(question_author)
      visit question_path(question)
      click_on 'Set as best', match: :first

      within '.best-answer' do
        expect(page).to have_content answer.body
      end
    end

    scenario 'author resets best answer', js: true do
      sign_in(question_author)
      visit question_path(question)
      click_on 'Set as best', match: :first

      within '.best-answer' do
        expect(page).to have_content answer.body
      end

      click_on 'Set as best'

      within '.best-answer' do
        expect(page).to_not have_content answer.body
        expect(page).to have_content same_answer.body
      end
    end

    scenario 'as not author doesnt set best answer' do
      sign_in(not_author)
      visit question_path(question)

      expect(page).to_not have_content 'Set as best'
    end

    scenario 'Unauthenticated user tries to set best answer' do
      visit question_path(question)

      expect(page).to_not have_content 'Set as best'
    end
  end
end
