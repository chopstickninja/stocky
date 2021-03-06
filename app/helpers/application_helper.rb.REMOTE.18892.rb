module ApplicationHelper
  require 'yql'
  require 'json'

    # WHEN [AAPL] INCREASES BY .01 IN 1 DAY
    # WHEN [GOOG] INCREASES BY .05 IN 1 WEEK FOR 182 DAYS
    # =>
    # when ticker change by increment per duration for length
  
  class Parser

    def get_prices(ticker, duration_examined)
      yql = Yql::Client.new
      yql.format = "json"
      daily_data = [] #daily prices IPO - now
      res = [0] #temp holder for year's prices
      endDate = DateTime.now
      query = Yql::QueryBuilder.new 'yahoo.finance.historicaldata'
      query.select = 'date, Open, High, Low, Volume, Adj_close'
      yql.query = query
      
      duration_examined.times do
        break if res.length == 0
        startDate = endDate - 1.year
        query.conditions = { 
          :symbol => ticker, 
          :startDate => "#{startDate.year}-#{startDate.month}-#{startDate.day}", 
          :endDate => "#{endDate.year}-#{endDate.month}-#{endDate.day}" 
        }
        res = JSON.parse(yql.get.show)["query"]["results"]["quote"]
        daily_data += res
        endDate = endDate - 1.year
      end
      daily_data
    end

    def find_ranges(ticker, change, duration, length = 0, duration_examined = 10)
      days = [] #days that trigger entry signal
      daily_data = get_prices(ticker, duration_examined)
      
      daily_data.each_with_index do |day_data, idx|
        start = day_data
        end_d = daily_data[idx + duration - 1]
        if end_d && (start["High"].to_f - end_d["Low"].to_f) / start["High"].to_f <= change ||
          end_d && (start["Low"].to_f - end_d["High"].to_f) / start["Low"].to_f >= change
          days << DateTime.new(*end_d["date"].split("-").map(&:to_i))
        end
      end

      days
    end
    puts find_ranges("GOOG", 0.01, 10, 180)
  end
end
      #   b. redis