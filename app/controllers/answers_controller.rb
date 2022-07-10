class AnswersController < ApplicationController
  include Voted

  before_action :authenticate_user!
  before_action :find_answer, only: %i[update destroy]

  after_action :publish_answer, only: %i[create]

  authorize_resource

  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.create(answer_params)
    current_user.answers << @answer
    @answer.save
  end

  def destroy
    @answer.destroy
    @question = @answer.question
  end

  def update
    @answer.update(answer_params)
    @question = @answer.question
  end

  private

  def answer_params
    params.require(:answer).permit(:body, files: [], links_attributes: %i[name url])
  end

  def find_answer
    @answer = Answer.with_attached_files.find(params[:id])
  end

  def publish_answer
    return if @answer.errors.any?

    ActionCable.server.broadcast(
      "answers_#{@answer.question.id}",
      author_id: @answer.user.id,
      page: render_answer
    )
  end

  def render_answer
    ApplicationController.render(
      partial: 'answers/answer_for_channel',
      locals: {
        answer: @answer
      }
    )
  end
end
