import capitalize from './capitalize';

describe('capitalize', () => {
  test('capitalizes the first letter of a lowercase word', () => {
    expect(capitalize('hello')).toBe('Hello');
  });

  test('keeps an already capitalized word capitalized', () => {
    expect(capitalize('World')).toBe('World');
  });

  test('capitalizes a single character string', () => {
    expect(capitalize('a')).toBe('A');
  });

  test('capitalizes the first word in a sentence', () => {
    expect(capitalize('the quick brown fox')).toBe('The quick brown fox');
  });

  test('handles an empty string', () => {
    expect(capitalize('')).toBe('');
  });

  test('leaves non-alphabetic starting characters as-is', () => {
    expect(capitalize('123hello')).toBe('123hello');
    expect(capitalize('!hello')).toBe('!hello');
  });

  test('returns empty string for non-string or falsy input', () => {
    expect(capitalize(null)).toBe('');
    expect(capitalize(undefined)).toBe('');
    expect(capitalize(123)).toBe('');
  });
});
