function analyzeArray(arr) {
  if (!Array.isArray(arr) || arr.length === 0) {
    return {
      average: null,
      min: null,
      max: null,
      length: 0,
    };
  }

  const length = arr.length;
  const min = Math.min(...arr);
  const max = Math.max(...arr);
  const sum = arr.reduce((acc, curr) => acc + curr, 0);
  const average = sum / length;

  return {
    average,
    min,
    max,
    length,
  };
}

export default analyzeArray;
