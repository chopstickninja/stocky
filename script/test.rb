p "hello!!!"
query = "when AAPL increases by 5% in 1 day use 3% of portfolio to buy AAPL."
callback = "when AAPL decreases by 3% in 1 days exit"
duration_examined = 1
max_open_trades = 1

p obj = ApplicationHelper::Parser.new(query, callback, duration_examined,max_open_trades)
