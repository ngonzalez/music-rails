Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :music, only: [:index, :show] do
    collection do
      get :search
    end
  end

  resources :stats, only: [:index]

  resources :tracks, only: [:show]

  resources :streams, only: [:create]

  resources :uploads, only: [:new, :create]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get '*unmatched_route', :to => 'errors#raise_not_found!'

end
