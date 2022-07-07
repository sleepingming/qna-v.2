require 'rails_helper'

feature 'User can comment', %q{
  In order to write additional info
  As an authenticated user
  I'd like to be able to comment
} do

  given!(:user) { create(:user) }
  given!(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question) }

  describe "Authenticated user", js: true do
    background do
      sign_in(user)

      visit question_path(question)
    end

    scenario 'create comment' do

      fill_in "comment-body#{question.id}", with: 'text text', match: :first

      click_on 'Add comment', match: :first
      visit question_path(question)

      expect(page).to have_content 'text text'
    end

    scenario "comment appears on another user's page" do
      Capybara.using_session('user') do
        sign_in(user)
        visit question_path(question)
      end

      Capybara.using_session('guest') do
        visit question_path(question)
      end

      Capybara.using_session('user') do

        fill_in "comment-body#{question.id}", with: 'text text text', match: :first

        click_on 'Add comment', match: :first
      end

      Capybara.using_session('guest') do
        visit question_path(question)
        expect(page).to have_content 'text text text'
      end
    end
  end
end
