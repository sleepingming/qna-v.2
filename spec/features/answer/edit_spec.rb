require 'rails_helper'

feature 'User can edit answer', "
  In order to correct mistakes
  As an author of answer
  I'd like to be able to edit my answer
" do
  given!(:user) { create(:user) }
  given!(:not_author) { create(:user) }
  given!(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, user: user) }
  given!(:link) { create(:link, linkable: answer) }

  scenario 'Unauthenticated user can not edit answer' do
    visit question_path(question)

    expect(page).to_not have_link 'Edit'
  end

  describe 'Authenticated user', js: true do
    scenario 'edits his answer' do
      sign_in(user)
      visit question_path(question)
      click_on 'Edit'

      within '.answers' do
        fill_in 'Body', with: 'edited answer'
        click_on 'Save'

        expect(page).to_not have_content answer.body
        expect(page).to have_content 'edited answer'
      end
    end

    scenario 'edits his answer with errors' do
      sign_in(user)
      visit question_path(question)
      click_on 'Edit'

      within '.answers' do
        fill_in 'Body', with: ''
        click_on 'Save'

        expect(page).to have_content answer.body
        expect(page).to have_selector 'textarea'
      end
      expect(page).to have_content "Body can't be blank"
    end

    scenario "tries to edit other user's question" do
      sign_in(not_author)
      visit question_path(question)
      expect(page).to_not have_link 'Edit'
    end

    scenario 'edit an answer with attached files' do
      sign_in(user)

      visit question_path(question)
      click_on 'Edit answer'

      within '.answers' do
        fill_in 'Body', with: 'text text'

        attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
        click_on 'Save'
      end

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end

    scenario 'delete link from his answer', js: true do
      sign_in(user)

      visit question_path(question)

      expect(page).to have_link 'MyLink', href: 'http://google.com'

      click_on 'Delete link'

      expect(page).to_not have_link 'MyLink', href: 'http://google.com'
    end

    scenario 'tries to delete link from not his answer', js: true do
      sign_in(not_author)

      visit question_path(question)

      expect(page).to_not have_link 'Delete link'
    end

    scenario 'adds link while editing their answer', js: true do
      sign_in(user)

      visit question_path(question)

      click_on 'Edit answer', match: :first

      within '.answers' do
        fill_in 'Link name', with: 'Google', match: :first
        fill_in 'Url', with: 'http://google.com', match: :first
      end

      click_on 'Save'

      expect(page).to have_link 'Google', href: 'http://google.com'
    end
  end
end
