p "hello!!!"
query = "where AAPL increases by 5% in 1 day use 3% of portfolio to buy AAPL."
callback = "where AAPL increases by 5% in 3 days or AAPL decreases by 10% in 3 days exit"
duration_examined = 1
max_open_trades = 10

p obj = Parser.new(query, callback, duration_examined,max_open_trades)
p 'hello'