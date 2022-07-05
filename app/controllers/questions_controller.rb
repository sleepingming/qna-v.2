class QuestionsController < ApplicationController
  include Voted
  
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, only: %i[show edit update destroy set_best_answer]

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
    if current_user.author_of?(@question)
      @question.destroy
      redirect_to questions_path, notice: 'Question is successfully deleted.'
    else
      redirect_to @question, notice: 'You are not an author'
    end
  end

  def set_best_answer
    if current_user.author_of?(@question)
      answer = Answer.find(params[:answer])
      if @question.set_best_answer(answer) && @question.reward.present?
        answer.user.give_reward(@question.reward)
      end
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, files: [],
      links_attributes: [:name, :url],
      reward_attributes: [:title, :image])
  end

  def load_question
    @question = Question.with_attached_files.find(params[:id])
  end
end
