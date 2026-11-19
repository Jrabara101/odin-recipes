import caesarCipher from './caesarCipher';

describe('caesarCipher', () => {
  test('shifts lowercase letters correctly', () => {
    expect(caesarCipher('abc', 1)).toBe('bcd');
  });

  test('wraps from z to a', () => {
    expect(caesarCipher('xyz', 3)).toBe('abc');
  });

  test('preserves uppercase and lowercase letters', () => {
    expect(caesarCipher('HeLLo', 3)).toBe('KhOOr');
  });

  test('wraps uppercase letters from Z to A', () => {
    expect(caesarCipher('XYZ', 3)).toBe('ABC');
  });

  test('leaves punctuation, spaces, and non-alphabetical characters unchanged', () => {
    expect(caesarCipher('Hello, World!', 3)).toBe('Khoor, Zruog!');
  });

  test('handles large shift factors greater than 26', () => {
    expect(caesarCipher('abc', 29)).toBe('def'); // 29 % 26 === 3
  });

  test('handles negative shift factors', () => {
    expect(caesarCipher('abc', -3)).toBe('xyz');
    expect(caesarCipher('Khoor, Zruog!', -3)).toBe('Hello, World!');
  });

  test('handles negative shift factors larger than 26', () => {
    expect(caesarCipher('def', -29)).toBe('abc');
  });

  test('handles a shift factor of 0', () => {
    expect(caesarCipher('Hello, World!', 0)).toBe('Hello, World!');
  });

  test('defaults shift to 0 if not provided', () => {
    expect(caesarCipher('Hello, World!')).toBe('Hello, World!');
  });

  test('returns empty string if input is not a string', () => {
    expect(caesarCipher(null)).toBe('');
    expect(caesarCipher(undefined)).toBe('');
    expect(caesarCipher(123)).toBe('');
  });

  test('handles empty strings', () => {
    expect(caesarCipher('', 5)).toBe('');
  });
});
