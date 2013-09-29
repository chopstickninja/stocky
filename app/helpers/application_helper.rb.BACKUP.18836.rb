module ApplicationHelper
<<<<<<< HEAD

  class Parser
    TICKER = /[A-Z]{1,4}/i
    CHANGE = /increases|decreases/i
    PERCENTAGE = /([0-9]+)%/i
    NUM_WITH_UNIT =/([0-9]+) (months?|days?|weeks?|years?)/i
    ACTION =/buy|sell/i
    IN_PER= /(?:IN|PER) #{NUM_WITH_UNIT}(?: FOR #{NUM_WITH_UNIT})?/i
    COND_REGEX = /(?:when|or) (#{TICKER}(?: or #{TICKER})*) (#{CHANGE}) by #{PERCENTAGE} #{IN_PER} /i
    DO_REGEX = /use #{PERCENTAGE} of (portfolio|free cash) to (#{ACTION}) (#{TICKER})/i
    QUERY_REGEX = /#{COND_REGEX}+(?:#{DO_REGEX}|EXIT)/i

    def initialize(query)
        query.scan(QUERY_REGEX) do |tickers, direction,
                                    cond_delta, |
        
        end

    end
    

    private

    def 

=======
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
>>>>>>> 1e7b3d73254e10f20a56b37c11527134ef6c7936
end
      #   b. redis
