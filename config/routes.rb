Stocky::Application.routes.draw do

  resources :strategies, :only => [:show, :index, :create, :update, :destroy]

  resources :users, :only => [:create, :index, :new]
  resource :session
end
