class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :user
  belongs_to :answer, class_name: 'Answer', foreign_key: 'best_answer_id', optional:true

  validates :title, :body, presence: true

  def set_best_answer(answer)
    if self.answers.include?(answer)
      self.assign_attributes( { best_answer_id: answer.id } )
      self.save
    end
  end
end
