class AnswersController < ApplicationController
  before_action :authenticate_user!
  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.create(answer_params)
    current_user.answers << @answer
    @answer.save
  end

  def destroy
    @answer = Answer.find(params[:id])
    if current_user.author_of?(@answer)
      @answer.destroy
      redirect_to @answer.question, notice: 'Answer is successfully deleted.'
    else
      redirect_to @answer.question, notice: 'You are not an author'
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
