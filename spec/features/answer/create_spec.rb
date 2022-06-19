require 'rails_helper'

feature 'User can create answer', "
  In order to help to community
  As an any user
  I'd like to be able to answer the question
" do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  describe 'Authenticated user', js: true do
    background do
      sign_in(user)

      visit question_path(question)
    end

    scenario 'add answer' do
      fill_in 'Body', with: 'text'
      click_on 'Send Answer'
      expect(page).to have_content 'text'
    end

    scenario 'answer with errors' do
      click_on 'Send Answer'
      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user tries to send answer' do
    visit question_path(question)
    fill_in 'Body', with: 'text'
    click_on 'Send Answer'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
