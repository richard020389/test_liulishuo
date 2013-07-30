TestLiulishuo::Application.routes.draw do
  resources :users, only: [:create, :new]
  resources :sessions, only: [:create, :new, :destroy]

  get "/welcome" => "welcome#index"

  get 'register' => 'users#new', as: 'register'
  get 'login' => 'sessions#new', as: 'login'
  get 'logout' => 'sessions#delete', as: 'logout'


  root to: "welcome#index"
end
