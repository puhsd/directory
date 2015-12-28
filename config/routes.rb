Rails.application.routes.draw do
  resources :users do
    post 'import', :on => :collection
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root :to => 'users#index'

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
