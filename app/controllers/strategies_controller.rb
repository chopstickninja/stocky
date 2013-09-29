class StrategiesController < ApplicationController
  def show
    @strategy = Strategy.find_by_id(params[:id])
    render :show
  end
  
  def index
    @strategies = Strategy.find_all_by_user_id(current_user.id)
    render :index
  end
  
  def create
    
  end
  
  def update
  end
  
  def destroy
  end
end