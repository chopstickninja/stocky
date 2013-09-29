require 'yql'
require 'json'
require 'date'

  # WHEN [AAPL] INCREASES BY .01 IN 1 DAY
  # WHEN [GOOG] INCREASES BY .05 IN 1 WEEK FOR 7 WEEKS
  # =>
  # when ticker change by increment in duration for length

class Parser
  attr_accessor :duration_examined, :stock_data

  def initialize
    @stock_data = {}
  end

    def get_prices(ticker)
      if @stock_data[ticker]
        if @stock_data[ticker].keys.count > 250 * @duration_examined
          return @stock_data[ticker]
        end
      else
        @stock_data[ticker] = {}
        yql = Yql::Client.new
        yql.format = "json"
        daily_data = [] #daily prices IPO - now
        res = [0] #temp holder for year's prices
        endDate = DateTime.now
        query = Yql::QueryBuilder.new 'yahoo.finance.historicaldata'
        query.select = 'date, Open, High, Low, Volume, Adj_Close'
        yql.query = query
        
        @duration_examined.times do
          break if res.length == 0
          startDate = endDate - 1.year
          query.conditions = { 
            :symbol => ticker, 
            :startDate => "#{startDate.year}-#{startDate.month}-#{startDate.day}", 
            :endDate => "#{endDate.year}-#{endDate.month}-#{endDate.day}" 
          }
          res = JSON.parse(yql.get.show)["query"]["results"]["quote"]

          res.each do |day_data|
            date = day_data.delete("date")
            @stock_data[ticker][date] = day_data
          end

          endDate = endDate - 1.year
        end
      end
    end

    def find_ranges(ticker, change, duration, length = 1)
      days = [] #days that trigger entry signal
      daily_data = @stock_data[ticker]
      unless @stock_data[ticker].keys.count > 250 * @duration_examined
        get_prices(ticker)
      end

      decrease = change < 0 ? true : false

      sorted_keys = daily_data.keys.sort
      
      sorted_keys.each_with_index do |day_string, idx|
        start = daily_data[day_string]
        end_d = daily_data[sorted_keys[idx + duration - 1]]
        break unless end_d
        max_incr = (end_d["High"].to_f - start["Low"].to_f) / end_d["High"].to_f
        max_decr = (end_d["Low"].to_f - start["High"].to_f) / end_d["Low"].to_f

        if decrease && max_decr <= change || !decrease && max_incr >= change
          days << sorted_keys[idx + duration - 1]
        end
      end

      # if length > 1
      #   successive_days = []
      #   # for each entry in days, look at it + the next LENGTH - 1
      #   # entries. determine if they're each DURATION apart (in
      #   # trading days)
      #   (days.count - 1).times do |idx|
      #     start = days[idx]
      #     count = 0
      #     end_d = days[idx + 1 + count]
      #     while are_successive_days?(start, end_d, duration) &&
      #       count < length
      #       count += 1
      #       end_d = days[idx + 1 + count]
      #     end
      #     successive_days << days[idx] if count == length - 1
      #   end
      #   return successive_days
      # end
      days
    end

    def are_successive_days?(start_d, end_d, duration)
      # look through each day in days. if hit a string
      # of length successive days spaced by duration,
      # extract that part and return
      start_date = DateTime.new(*start_d.split("-").map(&:to_i))
      end_date = DateTime.new(*end_d.split("-").map(&:to_i))
      return true if end_date - start_date == duration
      false
    end
    # (queries array, callback dates array, max open trades)
    # p = Parser.new()
    # puts p.find_ranges("GOOG", 0.01, 10, 180)
end