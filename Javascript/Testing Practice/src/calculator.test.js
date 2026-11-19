import calculator from './calculator';

describe('calculator', () => {
  describe('add', () => {
    test('adds two positive integers', () => {
      expect(calculator.add(2, 3)).toBe(5);
    });

    test('adds negative numbers', () => {
      expect(calculator.add(-2, -3)).toBe(-5);
      expect(calculator.add(-2, 5)).toBe(3);
    });

    test('adds floating point numbers accurately', () => {
      expect(calculator.add(0.1, 0.2)).toBeCloseTo(0.3);
    });

    test('adds with zero', () => {
      expect(calculator.add(5, 0)).toBe(5);
    });
  });

  describe('subtract', () => {
    test('subtracts two positive integers', () => {
      expect(calculator.subtract(5, 2)).toBe(3);
    });

    test('subtracts resulting in negative number', () => {
      expect(calculator.subtract(2, 5)).toBe(-3);
    });

    test('subtracts negative numbers', () => {
      expect(calculator.subtract(-5, -2)).toBe(-3);
      expect(calculator.subtract(5, -2)).toBe(7);
    });

    test('subtracts floating point numbers', () => {
      expect(calculator.subtract(0.3, 0.1)).toBeCloseTo(0.2);
    });
  });

  describe('divide', () => {
    test('divides two positive numbers evenly', () => {
      expect(calculator.divide(10, 2)).toBe(5);
    });

    test('divides with decimal result', () => {
      expect(calculator.divide(7, 2)).toBe(3.5);
    });

    test('divides negative numbers', () => {
      expect(calculator.divide(-10, 2)).toBe(-5);
      expect(calculator.divide(-10, -2)).toBe(5);
    });

    test('throws or returns Infinity when dividing by zero', () => {
      expect(calculator.divide(5, 0)).toBe(Infinity);
    });
  });

  describe('multiply', () => {
    test('multiplies two positive numbers', () => {
      expect(calculator.multiply(3, 4)).toBe(12);
    });

    test('multiplies with zero', () => {
      expect(calculator.multiply(5, 0)).toBe(0);
      expect(calculator.multiply(0, 5)).toBe(0);
    });

    test('multiplies negative numbers', () => {
      expect(calculator.multiply(-3, 4)).toBe(-12);
      expect(calculator.multiply(-3, -4)).toBe(12);
    });

    test('multiplies floating point numbers', () => {
      expect(calculator.multiply(0.2, 0.3)).toBeCloseTo(0.06);
    });
  });
});
