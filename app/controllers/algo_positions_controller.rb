class AlgoPositionsController < ApplicationController
  def index
      @positions = [{:buyorsell=>"buy", :date=>"2012-09-18", :open=>"15.65", :high=>"16.17", :low=>"15.60", :volume=>"42449600", :price=>"15.91"}, 
      			{:buyorsell=>"buy", :date=>"2012-10-23", :open=>"16.53", :high=>"16.79", :low=>"16.26", :volume=>"71575400", :price=>"16.67"}, 
      			{:buyorsell=>"buy", :date=>"2013-03-01", :open=>"21.36", :high=>"22.28", :low=>"21.26", :volume=>"33776700", :price=>"21.94"}, 
      			{:buyorsell=>"buy", :date=>"2013-04-15", :open=>"24.72", :high=>"24.99", :low=>"23.83", :volume=>"28129600", :price=>"23.98"}, 
      			{:buyorsell=>"buy", :date=>"2013-06-25", :open=>"24.29", :high=>"25.01", :low=>"24.23", :volume=>"18883900", :price=>"24.96"}, 
      			{:buyorsell=>"buy", :date=>"2013-07-03", :open=>"24.84", :high=>"25.64", :low=>"24.82", :volume=>"6059100", :price=>"25.59"}, 
      			{:buyorsell=>"buy", :date=>"2013-07-18", :open=>"29.57", :high=>"29.83", :low=>"28.73", :volume=>"35025600", :price=>"29.66"}, 
      			{:buyorsell=>"buy", :date=>"2013-08-12", :open=>"27.55", :high=>"28.37", :low=>"27.50", :volume=>"16561900", :price=>"28.35"}, 
      			{:buyorsell=>"sell", :date=>"2013-01-29", :open=>"20.87", :high=>"20.88", :low=>"19.68", :volume=>"57652300", :price=>"19.70"}, 
      			{:buyorsell=>"sell", :date=>"2013-06-24", :open=>"24.98", :high=>"25.09", :low=>"23.82", :volume=>"37006200", :price=>"24.07"}, 
      			{:buyorsell=>"sell", :date=>"2013-07-17", :open=>"27.66", :high=>"29.73", :low=>"27.52", :volume=>"83791400", :price=>"29.66"}]

    render :json => @positions
  end
end
