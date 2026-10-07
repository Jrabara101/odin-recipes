def stock_picker(prices)
  return nil if prices.nil? || prices.length < 2

  min_price_day = 0
  best_buy_day = 0
  best_sell_day = 1
  max_profit = prices[1] - prices[0]

  # Iterate through each subsequent day to evaluate selling on that day
  (1...prices.length).each do |current_day|
    current_price = prices[current_day]

    # Calculate profit if buying at the lowest price seen so far and selling today
    current_profit = current_price - prices[min_price_day]

    if current_profit > max_profit
      max_profit = current_profit
      best_buy_day = min_price_day
      best_sell_day = current_day
    end

    # Update the lowest buy day seen so far for future sell opportunities
    if current_price < prices[min_price_day]
      min_price_day = current_day
    end
  end

  [best_buy_day, best_sell_day]
end

# Tests and examples from The Odin Project
if __FILE__ == $PROGRAM_NAME
  puts "--- Test 1: The Odin Project Example ---"
  prices1 = [17, 3, 6, 9, 15, 8, 6, 1, 10]
  result1 = stock_picker(prices1)
  profit1 = prices1[result1[1]] - prices1[result1[0]]
  puts "Prices: #{prices1.inspect}"
  puts "Result: #{result1.inspect} (Buy Day #{result1[0]} @ $#{prices1[result1[0]]}, Sell Day #{result1[1]} @ $#{prices1[result1[1]]})"
  puts "Profit: $#{profit1}"
  puts "Expected: [1, 4] for a profit of $12"
  puts

  puts "--- Test 2: Lowest Price on the Last Day ---"
  prices2 = [10, 8, 15, 1]
  result2 = stock_picker(prices2)
  profit2 = prices2[result2[1]] - prices2[result2[0]]
  puts "Prices: #{prices2.inspect}"
  puts "Result: #{result2.inspect} (Buy Day #{result2[0]} @ $#{prices2[result2[0]]}, Sell Day #{result2[1]} @ $#{prices2[result2[1]]})"
  puts "Profit: $#{profit2}"
  puts "Expected: [1, 2] for a profit of $7"
  puts

  puts "--- Test 3: Highest Price on the First Day ---"
  prices3 = [25, 2, 8, 4, 12, 1]
  result3 = stock_picker(prices3)
  profit3 = prices3[result3[1]] - prices3[result3[0]]
  puts "Prices: #{prices3.inspect}"
  puts "Result: #{result3.inspect} (Buy Day #{result3[0]} @ $#{prices3[result3[0]]}, Sell Day #{result3[1]} @ $#{prices3[result3[1]]})"
  puts "Profit: $#{profit3}"
  puts "Expected: [1, 4] for a profit of $10"
end
