Rails.application.routes.draw do
  devise_for :users
  resources :questions, shallow: true do
    patch :set_best_answer, on: :member
    resources :answers, except: %i[show index]
  end

  resources :files, only: :destroy

  root to: 'questions#index'
end
