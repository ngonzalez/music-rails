Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :music, only: [:index, :show]

  resources :tracks, only: [:show]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get '*unmatched_route', :to => 'errors#raise_not_found!'

end
