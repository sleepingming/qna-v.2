require 'rails_helper'

feature 'User can edit his question', "
  In order to correct mistakes
  As an author of question
  I'd like to be able to edit my question
" do
  given!(:user) { create(:user) }
  given!(:not_author) { create(:user) }
  given!(:question) { create(:question, user: user) }

  scenario 'Unauthenticated can not edit answer' do
    visit question_path(question)

    expect(page).to_not have_link 'Edit question'
  end

  describe 'Authenticated user', js: true do
    scenario 'edits his question' do
      sign_in(user)

      visit question_path(question)
      click_on 'Edit question'

      within '.question' do
        fill_in 'Title', with: 'edited question title'
        fill_in 'Body', with: 'edited question body'
        click_on 'Save'

        expect(page).to_not have_content question.title
        expect(page).to_not have_content question.body
        expect(page).to have_content 'edited question title'
        expect(page).to have_content 'edited question body'
        expect(page).to_not have_selector 'textarea'
      end
    end

    scenario 'edits his question with errors' do
      sign_in(user)

      visit question_path(question)
      click_on 'Edit question'

      within '.question' do
        fill_in 'Title', with: ''
        fill_in 'Body', with: ''
        click_on 'Save'

        expect(page).to have_content question.title
        expect(page).to have_content question.body
        expect(page).to have_selector 'textarea'
      end

      expect(page).to have_content "Title can't be blank"
      expect(page).to have_content "Body can't be blank"
    end

    scenario "tries to edit other user's question" do
      sign_in(not_author)

      visit question_path(question)

      expect(page).to_not have_link 'Edit question'
    end

    scenario 'Authenticated user edit a question with attached files' do
      sign_in(user)

      visit question_path(question)
      click_on 'Edit question'

      within '.question' do
        fill_in 'Title', with: 'Edited question'
        fill_in 'Body', with: 'text text'

        attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
        click_on 'Save'
      end

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end
  end
end
