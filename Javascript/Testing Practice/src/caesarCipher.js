function isLowerCase(char) {
  const code = char.charCodeAt(0);
  return code >= 97 && code <= 122; // 'a' - 'z'
}

function isUpperCase(char) {
  const code = char.charCodeAt(0);
  return code >= 65 && code <= 90; // 'A' - 'Z'
}

function shiftChar(char, shift) {
  const normalizedShift = ((shift % 26) + 26) % 26;

  if (isLowerCase(char)) {
    const code = char.charCodeAt(0) - 97;
    return String.fromCharCode(((code + normalizedShift) % 26) + 97);
  }

  if (isUpperCase(char)) {
    const code = char.charCodeAt(0) - 65;
    return String.fromCharCode(((code + normalizedShift) % 26) + 65);
  }

  return char;
}

function caesarCipher(str, shift = 0) {
  if (typeof str !== 'string') return '';
  return str
    .split('')
    .map((char) => shiftChar(char, shift))
    .join('');
}

export default caesarCipher;
