require 'rails_helper'

feature 'User can vote for question', "
  In order to estimate question
  As an authenticate user
  I'd like to be able to vote for question
" do

  given!(:question) { create(:question) }
  given(:user) { create(:user) }
  given!(:user_question) { create(:user) }
  given!(:answer) { create(:question, user: user) }

  scenario 'unauthenticated user can not vote for question' do
    visit question_path(question)

    within '.question' do
      expect(page).to_not have_link 'Like'
      expect(page).to_not have_link 'Dislike'
      expect(page).to_not have_link 'Cancel vote'
    end
  end

  describe 'Authenticated user', js: true do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'can like the question' do
      within '.vote' do
        click_on 'Like'
      end

      within ".votable-score-#{question.id}" do
        expect(page).to have_content('1')
      end
    end

    scenario 'can dislike the question' do
      within '.vote' do
        click_on 'Dislike'
      end

      within ".votable-score-#{question.id}" do
        expect(page).to have_content('-1')
      end
    end

    scenario 'can cancel vote for the question' do
      within '.vote' do
        click_on 'Dislike'
        click_on 'Cancel'
      end

      within ".votable-score-#{question.id}" do
        expect(page).to have_content('0')
      end
    end
  end
end
