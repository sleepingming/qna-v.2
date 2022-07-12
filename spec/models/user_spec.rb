require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:votes).dependent(:destroy) }
  it { should have_many(:rewards) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  let(:author) { create(:user) }
  let(:user) { create(:user) }
  let(:not_author) { create(:user) }
  let(:question) { create(:question, user: author) }
  let(:answer) { create(:answer, user: author, question: question) }
  let(:reward) { create(:reward, question: question) }
  let!(:subscribtion) {create(:subscribtion, user: user, question: question)}

  it 'check user is an author' do
    expect(question.user.author_of?(question)).to eq true
  end

  it "check user isn't an author" do
    user = create(:user)

    expect(user.author_of?(question)).to eq false
  end

  it 'gains reward for their answer' do
    question.set_best_answer(answer)
    author.give_reward(reward)

    expect(author.rewards).to include(reward)
  end

  it "doesn't gains reward for others answers" do
    question.set_best_answer(answer)
    author.give_reward(reward)

    expect(not_author.rewards).to_not include(reward)
  end

  it "check user subscribed to question" do
    expect(user).to be_subscribed(question)
  end

  it "get user subscribtion" do
    expect(user.subscribed(question)).to be_an_instance_of(Subscribtion)
  end
end
