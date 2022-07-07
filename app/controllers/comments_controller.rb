class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_commentable, only: :create

  after_action :publish_comment, only: :create

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.json do
          render json: [comment: @comment, key: 'comment']
        end
      else
        format.json do
          render json: [commentable_class: @commentable.class.to_s.downcase,
                        commentable_id: @commentable.id,
                        errors: @comment.errors.full_messages], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def publish_comment
    if @comment.persisted?
      question = @commentable.instance_of?(Question) ? @commentable : @commentable.question
      ActionCable.server.broadcast(
        "questions/#{question.id}/answers",
        { comment_text: @comment.body,
          parent_id: @commentable.id,
          author_id: current_user.id }
      )
    end
  end

  def find_commentable
    params[:question_id] ? @commentable = Question.find(params[:question_id]) : @commentable = Answer.find(params[:answer_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
