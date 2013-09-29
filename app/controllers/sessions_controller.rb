class SessionsController < ApplicationController
	before_filter :require_no_current_user!, :only => [:create, :new]
	before_filter :require_current_user!, :only => [:destroy]

	def create
		user = User.find_by_credentials(
      		params[:user][:username],
      		params[:user][:password]
    	)
 		if user.nil?
      		flash[:errors] = "Credentials were wrong. Please try again."
      		render :new
    	else
      		user.reset_session_token!
      		self.current_user = user
      		redirect_to users_url
    	end
	end

	def new
		render :new
	end
end
