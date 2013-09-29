class Strategy < ActiveRecord::Base
  attr_accessible :query, :callback, :user_id, :start_date
  
  belongs_to :user
end
