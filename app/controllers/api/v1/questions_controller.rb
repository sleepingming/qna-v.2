class Api::V1::QuestionsController < Api::V1::BaseController
  before_action :load_question, only: %i[show update destroy]

  authorize_resource

  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    render json: @question
  end

  def create
    @question = current_resource_owner.questions.build(question_params)
    if @question.save
      render json: @question
    else
      head :unprocessable_entity
    end
  end

  def update
    if @question.update(question_params)
      render json: @question
    else
      head :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
  end

  private

  def question_params
    params.require(:question).permit(:title, :body)
  end

  def load_question
    @question = Question.with_attached_files.find(params[:id])
  end
end
