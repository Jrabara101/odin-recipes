def caesar_cipher(string, shift_factor)
  # Wrap shifts within the 26-letter alphabet range (handles negative shifts & shifts > 26)
  shift = shift_factor % 26

  string.chars.map do |char|
    if char.between?('a', 'z')
      base = 'a'.ord
      (((char.ord - base + shift) % 26) + base).chr
    elsif char.between?('A', 'Z')
      base = 'A'.ord
      (((char.ord - base + shift) % 26) + base).chr
    else
      # Leave spaces, punctuation, numbers, and symbols unchanged
      char
    end
  end.join
end

# Example test from The Odin Project:
if __FILE__ == $PROGRAM_NAME
  puts caesar_cipher("What a string!", 5)
  # Expected output: "Bmfy f xywnsl!"
end
