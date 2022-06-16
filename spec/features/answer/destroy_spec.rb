require 'rails_helper'

feature 'User can destroy answer', "
  In order to delete wrong answer
  As an author
  I'd like to be able to delete a answer
" do
  given(:answer) { create(:answer) }
  given(:user) { create(:user) }

  describe 'Authenticated user' do
    scenario 'user is author' do
      sign_in(answer.user)
      visit question_path(answer.question)
      expect(page).to have_content 'Delete answer'
    end

    scenario 'user is not the author' do
      sign_in(user)
      visit question_path(answer.question)
      expect(page).to_not have_content 'Delete answer'
    end
  end

  scenario 'Unauthenticated user' do
    visit question_path(answer.question)
    expect(page).to_not have_content 'Delete answer'
  end
end
