require 'rails_helper'

feature 'User can view all their rewards', "
  In order to see progress
  As an user
  I'd like to be able to show user rewards
" do

  given(:not_reward_owner) { create(:user) }
  given(:reward_owner) { create(:user) }
  given(:question) { create(:question, user: not_reward_owner) }
  given!(:reward) { create(:reward, question: question, user: reward_owner) }


  describe 'Authenticated user' do
    scenario 'as reward owner tries to see their rewards', js: true do
      sign_in(reward_owner)
      visit user_rewards_path

      expect(page).to have_content reward.title
      expect(page).to have_content question.title
    end

    scenario 'as not reward owner tries to see their rewards', js: true do
      sign_in(not_reward_owner)
      visit user_rewards_path

      expect(page).to_not have_content reward.title
    end
  end

  describe 'Unauthenticated user' do
    scenario 'tries to see rewards' do
      visit questions_path

      expect(page).to_not have_content 'My rewards'
    end
  end
end
