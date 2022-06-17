class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_answer, only: %i[update destroy]
  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.create(answer_params)
    current_user.answers << @answer
    @answer.save
  end

  def destroy
    @answer.destroy if current_user.author_of?(@answer)
    @question = @answer.question
  end

  def update
    @answer.update(answer_params) if current_user.author_of?(@answer)
    @question = @answer.question
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end

  def find_answer
    @answer = Answer.find(params[:id])
  end
end
