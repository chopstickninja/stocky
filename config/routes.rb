Stocky::Application.routes.draw do
  resources :strategies, :only => [:show, :index, :create, :update, :destroy]
end
