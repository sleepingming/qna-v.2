require 'rails_helper'

RSpec.describe QuestionSubscriptionMailer, type: :mailer do
  describe 'new answer' do
    let(:mail) {QuestionSubscriptionMailer.new_answer}

    it "renders the headers" do
      expect(mail.subject).to eq("New answer")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end
end
