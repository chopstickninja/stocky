class UsersController < ApplicationController
	before_filter :require_current_user!, :only => [:index, :show]
	def create
	end

	def index
		render :index
	end
	
	def new
		render :new
	end

	def show
		@strategies = current_user.strategies
		render :show
	end
end
