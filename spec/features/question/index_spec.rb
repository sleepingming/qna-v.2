require 'rails_helper'

feature 'User can see all questions', "
  In order to find a needed question
  As an any user
  I'd like to see all questions
" do
  let!(:question) { create(:question) }

  describe 'Any user' do
    scenario 'sees all questions' do
      visit questions_path
      expect(page).to have_content question.title
    end
  end
end
