class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :body, :user_id, :created_at, :updated_at
  has_many :comments
  has_many :files
  has_many :links
  belongs_to :user
end
