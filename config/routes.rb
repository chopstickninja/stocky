Stocky::Application.routes.draw do

  resources :strategies, :only => [:show, :index, :create, :update, :destroy]
end

  resources :users, :only => [:create, :index, :new]
  resource :session
end
