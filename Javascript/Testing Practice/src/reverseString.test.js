import reverseString from './reverseString';

describe('reverseString', () => {
  test('reverses a simple word', () => {
    expect(reverseString('hello')).toBe('olleh');
  });

  test('reverses multiple words including spaces', () => {
    expect(reverseString('hello world')).toBe('dlrow olleh');
  });

  test('handles palindrome strings', () => {
    expect(reverseString('racecar')).toBe('racecar');
  });

  test('handles strings with numbers and punctuation', () => {
    expect(reverseString('12345!')).toBe('!54321');
  });

  test('handles single character string', () => {
    expect(reverseString('a')).toBe('a');
  });

  test('handles an empty string', () => {
    expect(reverseString('')).toBe('');
  });

  test('returns empty string if input is not a string', () => {
    expect(reverseString(null)).toBe('');
    expect(reverseString(undefined)).toBe('');
    expect(reverseString(123)).toBe('');
  });
});
