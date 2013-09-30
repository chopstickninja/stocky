Stocky::Application.routes.draw do

  resources :strategies, :only => [:show, :index, :create, :update, :destroy]

  resources :users, :only => [:create, :index, :new, :show]
  resource :session
  
  resources :algo_positions, :only => [:index]
  resources :hist_prices, :only => [:index]

  resources :algorithms, :only => [:index, :show, :create]
end
