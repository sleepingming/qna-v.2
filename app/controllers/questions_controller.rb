class QuestionsController < ApplicationController
  include Voted
  # include Commented

  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, only: %i[show edit update destroy set_best_answer]

  after_action :publish_question, only: %i[create]

  authorize_resource

  def index
    @questions = Question.all
    @question = if current_user
                  current_user.questions.new
                else
                  Question.new
                end
    @question.build_reward
  end

  def show
    @answer = Answer.new
    @answer.links.new
  end

  def new
    @question = Question.new
    @question.links.new
  end

  def update
    @question.update(links: [])
    @question.update(question_params)
  end

  def create
    @question = current_user.questions.build(question_params)
    if @question.save
      redirect_to @question, notice: 'Your question successfully created.'
    else
      render :new
    end
  end

  def destroy
    @question.destroy
    redirect_to questions_path, notice: 'Question is successfully deleted.'
  end

  def set_best_answer
    if current_user.author_of?(@question)
      answer = Answer.find(params[:answer])
      answer.user.give_reward(@question.reward) if @question.set_best_answer(answer) && @question.reward.present?
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, files: [],
                                                    links_attributes: %i[name url],
                                                    reward_attributes: %i[title image])
  end

  def load_question
    @question = Question.with_attached_files.find(params[:id])

    gon.question_id = @question.id
  end

  def publish_question
    return if @question.errors.any?

    ActionCable.server.broadcast(
      'questions',
      ApplicationController.render(
        partial: 'questions/question',
        locals: { question: @question,
                  current_user: current_user }
      )
    )
  end
end
