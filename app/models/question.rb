class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :user
  belongs_to :answer, class_name: 'Answer', foreign_key: 'best_answer_id', optional: true

  has_many_attached :files

  validates :title, :body, presence: true

  def set_best_answer(answer)
    if answers.include?(answer)
      assign_attributes({ best_answer_id: answer.id })
      save
    end
  end
end
