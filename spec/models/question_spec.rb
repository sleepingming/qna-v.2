require 'rails_helper'

RSpec.describe Question, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:answer).optional }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:links).dependent(:destroy) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :body }

  it { should accept_nested_attributes_for :links }

  let(:question) { create(:question) }
  let(:answer) { create(:answer, question: question) }
  let(:some_answer) { create(:answer) }

  describe 'Question' do
    it 'sets the best answer from his answers' do
      question.set_best_answer(answer)
      expect(question.best_answer_id).to eq answer.id
    end

    it 'sets the best answer from not his answers' do
      question.set_best_answer(some_answer)
      expect(question.best_answer_id).to_not eq some_answer.id
    end
  end

  it 'have many attached files' do
    expect(Question.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end
end
