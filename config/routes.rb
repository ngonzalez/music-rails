Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'music_folders#index'

  resources :music_folders, only: [:index, :show]

  resources :audio_files, only: [:show]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get '*unmatched_route', :to => 'errors#raise_not_found!'

end
