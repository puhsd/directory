Rails.application.routes.draw do
  resources :groups
  resources :titles
  # get 'sessions/create'
  # get 'sessions/destroy'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  get 'ldap_sync', to: 'users#ldap_sync', as: 'ldap_sync'


  resources :sessions, only: [:create, :destroy]


  resources :users  do
    post 'import', :on => :collection
    post 'default_url', :on => :collection
  end

  resources :titles do
    post 'extract', :on => :collection
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root :to => 'users#index'

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
