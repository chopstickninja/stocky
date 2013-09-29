Stocky::Application.routes.draw do
  resources :users, :only => [:create, :index, :new]
  resource :session
end