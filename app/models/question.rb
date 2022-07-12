class Question < ApplicationRecord
  include Votable
  include Commentable

  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_one :reward
  belongs_to :user
  belongs_to :answer, class_name: 'Answer', foreign_key: 'best_answer_id', optional: true

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank
  accepts_nested_attributes_for :reward, reject_if: :all_blank

  validates :title, :body, presence: true


  def set_best_answer(answer)
    if answers.include?(answer)
      assign_attributes({ best_answer_id: answer.id })
      save
    end
  end

end
