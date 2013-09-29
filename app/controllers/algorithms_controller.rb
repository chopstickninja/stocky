class AlgorithmsController < ApplicationController
  respond_to :json, :only => [:create, :show]

  def create
    # params: {query => "...", callback => "..."}
    parser = Parser.new(params[:query], params[:callback], params[:duration_examined],params[:max_open_trades])
    trades = parser.execute_query
    @algorithms = []
    trades.each do |idx, trade|
      @algorithms << trade
    end

    render :handlers => [:rabl]
  end

  def show
    # params: {day1, day2}
    
  end
end
