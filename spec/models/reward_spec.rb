require 'rails_helper'

RSpec.describe Reward, type: :model do
  it { should belong_to(:question) }
  it { should belong_to(:user).optional }

  it { should validate_presence_of :title }

  describe 'Reward model' do
    it "has one attached file" do
      expect(Reward.new.image).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end
end
