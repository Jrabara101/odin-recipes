import analyzeArray from './analyzeArray';

describe('analyzeArray', () => {
  test('analyzes an array of positive numbers', () => {
    expect(analyzeArray([1, 8, 3, 4, 2, 6])).toEqual({
      average: 4,
      min: 1,
      max: 8,
      length: 6,
    });
  });

  test('analyzes an array with a single number', () => {
    expect(analyzeArray([5])).toEqual({
      average: 5,
      min: 5,
      max: 5,
      length: 1,
    });
  });

  test('analyzes an array with negative numbers', () => {
    expect(analyzeArray([-2, 0, 2])).toEqual({
      average: 0,
      min: -2,
      max: 2,
      length: 3,
    });
  });

  test('analyzes an array with all negative numbers', () => {
    expect(analyzeArray([-10, -5, -15])).toEqual({
      average: -10,
      min: -15,
      max: -5,
      length: 3,
    });
  });

  test('calculates floating point average correctly', () => {
    expect(analyzeArray([1, 2])).toEqual({
      average: 1.5,
      min: 1,
      max: 2,
      length: 2,
    });
  });

  test('analyzes an array where all elements are identical', () => {
    expect(analyzeArray([4, 4, 4, 4])).toEqual({
      average: 4,
      min: 4,
      max: 4,
      length: 4,
    });
  });

  test('handles empty array gracefully', () => {
    expect(analyzeArray([])).toEqual({
      average: null,
      min: null,
      max: null,
      length: 0,
    });
  });

  test('handles non-array input gracefully', () => {
    expect(analyzeArray(null)).toEqual({
      average: null,
      min: null,
      max: null,
      length: 0,
    });
    expect(analyzeArray('not an array')).toEqual({
      average: null,
      min: null,
      max: null,
      length: 0,
    });
  });
});
