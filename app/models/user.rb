class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :rewards

  def author_of?(item)
    item.user_id == id
  end

  def give_reward(reward)
    self.rewards.push(reward) if self.answers.include?(Answer.find(reward.question.best_answer_id))
  end
end
