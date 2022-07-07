Rails.application.routes.draw do
  devise_for :users
  resources :questions, shallow: true do
    patch :set_best_answer, on: :member
    resources :answers, except: %i[show index]
  end

  resources :files, only: :destroy
  resources :links, only: :destroy
  get :user_rewards, to: 'rewards#index'

  concern :votable do
    member do
      post :like
      post :dislike
      delete :cancel_vote
    end
  end

  concern :commentable do
    resource :comments, only: :create
  end

  resources :questions, concerns: %i[votable commentable] do
    patch :set_best_answer, on: :member
    resources :answers, concerns: %i[votable commentable], shallow: true, except: %i[show index]
  end

  root to: 'questions#index'

  mount ActionCable.server => '/cable'
end
