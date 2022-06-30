require 'rails_helper'

feature 'User can add links to answer', "
  In order to provide additional info to my answer
  As an question's author
  I'd like to be able to add links
" do

  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:gist_url) { 'https://gist.github.com/sleepingming/a6441b150a7b2a5a377725ff8b6bba09' }

  scenario 'User adds link when give an answer', js: true do
    sign_in(user)
    visit question_path(question)

    fill_in 'Body', with: 'My answer'

    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'Send Answer'

    within '.answers' do
      expect(page).to have_link 'My gist', href: gist_url
    end
  end

  scenario 'User adds invalid link when answer', js: true do
    sign_in(user)
    visit question_path(question)
    fill_in 'Body', with: 'text'

    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: '123123'

    click_on 'Send Answer'

    expect(page).to_not have_link 'My gist', href: gist_url

    expect(page).to have_content 'Links url is invalid'
  end

end
