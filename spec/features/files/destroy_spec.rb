require 'rails_helper'

feature 'User can delete files', "
  In order to remove files
  As an author
  I'd like to be able to delete a file
" do
  describe 'Authenticated user' do
    given!(:user) { create(:user) }
    given!(:question) { create(:question, user: user) }
    given!(:answer) { create(:answer, user: user, question: question) }
    given(:not_author) { create(:user) }

    background do
      question.files.attach(io: File.open("#{Rails.root}/spec/rails_helper.rb"), filename: 'rails_helper.rb')
      answer.files.attach(io: File.open("#{Rails.root}/spec/rails_helper.rb"), filename: 'rails_helper.rb')
    end

    scenario 'deletes file of his question', js: true do
      sign_in(user)
      visit question_path(question)

      within('.question') do
        expect(page).to have_link 'rails_helper.rb'
        click_on 'Delete file'

        expect(page).to_not have_link('rails_helper.rb')
      end
    end

    scenario 'deletes file of his answer', js: true do
      sign_in(user)
      visit question_path(question)

      within('.answers') do
        expect(page).to have_link 'rails_helper.rb'
      end
      within('.answer-files') do
        click_on 'Delete file'
        expect(page).to_not have_link('rails_helper.rb')
      end
    end

    scenario 'tries to delete file of not his question', js: true do
      sign_in(not_author)
      visit question_path(question)

      within('.question') do
        expect(page).to have_link 'rails_helper.rb'
      end
      expect(page).to_not have_link('Delete file')
    end

    scenario 'tries to delete file of not his answer', js: true do
      sign_in(not_author)
      visit question_path(question)

      within('.answers') do
        expect(page).to have_link 'rails_helper.rb'
        expect(page).to_not have_link('Delete file')
      end
    end
  end
end
