require 'rails_helper'

feature 'User can add links to question', "
  In order to provide additional info to my question
  As an question's author
  I'd like to be able to add links
" do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/sleepingming/a6441b150a7b2a5a377725ff8b6bba09' }

  background do
    sign_in(user)
    visit new_question_path
  end

  scenario 'User adds link when asks question' do
    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'text'

    fill_in 'Link name', with: 'Google'
    fill_in 'Url', with: 'http://google.com'

    click_on 'Ask'

    expect(page).to have_link 'Google', href: 'http://google.com'
  end

  scenario 'User adds invalid link when asks question' do
    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'text'

    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: '123123'

    click_on 'Ask'

    expect(page).to_not have_link 'My gist', href: gist_url

    expect(page).to have_content 'Links url is invalid'
  end
end
