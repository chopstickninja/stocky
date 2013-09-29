class UsersController < ApplicationController
	before_filter :require_current_user!, :only => [:index]
	def create
	end

	def index
		render :index
	end
	
	def new
		render :new
	end
end
