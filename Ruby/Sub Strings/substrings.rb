def substrings(text, dictionary)
  lowercased_text = text.downcase

  dictionary.each_with_object(Hash.new(0)) do |word, counts|
    # Find all occurrences of the dictionary substring (case-insensitive)
    matches = lowercased_text.scan(word.downcase).length
    counts[word] = matches if matches > 0
  end
end

# Tests from The Odin Project:
if __FILE__ == $PROGRAM_NAME
  dictionary = ["below", "down", "go", "going", "horn", "how", "howdy", "it", "i", "low", "own", "part", "partner", "sit"]

  puts "--- Test 1: Single Word ---"
  puts "Input: 'below'"
  result1 = substrings("below", dictionary)
  puts "Result: #{result1}"
  puts "Expected: {\"below\"=>1, \"low\"=>1}"
  puts

  puts "--- Test 2: Multiple Words & Punctuation ---"
  phrase = "Howdy partner, sit down! How's it going?"
  puts "Input: '#{phrase}'"
  result2 = substrings(phrase, dictionary)
  puts "Result: #{result2}"
  puts "Expected: {\"down\"=>1, \"go\"=>1, \"going\"=>1, \"how\"=>2, \"howdy\"=>1, \"it\"=>2, \"i\"=>3, \"own\"=>1, \"part\"=>1, \"partner\"=>1, \"sit\"=>1}"
end
