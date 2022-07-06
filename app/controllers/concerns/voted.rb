module Voted
  extend ActiveSupport::Concern

  included do
    before_action :load_votable, only: %i[like dislike cancel_vote]
  end

  def like
    vote = @votable.vote(1, current_user)

    respond_to do |format|
      if vote.save
        format.json do
          render json: {
            score: @votable.score,
            id: @votable.id
          }
        end
      else
        format.json do
          render json: {
            errors: vote.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def dislike
    vote = @votable.vote(-1, current_user)

    respond_to do |format|
      if vote.save
        format.json do
          render json: {
            score: @votable.score,
            id: @votable.id
          }
        end
      else
        format.json do
          render json: {
            errors: vote.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def cancel_vote
    vote = @votable.cancel_vote(current_user)

    respond_to do |format|
      format.json do
        render json: {
          score: @votable.score,
          id: @votable.id
        }
      end
    end
  end

  private

  def model_klass
    controller_name.classify.constantize
  end

  def load_votable
    @votable = model_klass.find(params[:id])
  end
end
