require 'rails_helper'

feature 'User can destroy question', "
  In order to stop discuss
  As an author
  I'd like to be able to delete a question
" do
  given(:question) { create(:question) }
  given(:user) { create(:user) }

  describe 'Authenticated user' do
    scenario 'user is author' do
      sign_in(question.user)
      visit question_path(question)
      expect(page).to have_content 'Delete question'
    end

    scenario 'user is not the author' do
      sign_in(user)
      visit question_path(question)
      expect(page).to_not have_content 'Delete question'
    end
  end

  scenario 'Unauthenticated user' do
    visit question_path(question)
    expect(page).to_not have_content 'Delete question'
  end
end
