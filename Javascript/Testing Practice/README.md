# Project: Testing Practice (The Odin Project)

A suite of unit tests and JavaScript functions written using Test-Driven Development (TDD) with **Jest** and **Babel** (for ES Module import/export support).

## Implemented Functions

1. **`capitalize(str)`**
   - Returns string with the first character capitalized.
   - Preserves subsequent characters, handles empty strings, non-string inputs, and non-alphabetic starting characters.

2. **`reverseString(str)`**
   - Returns the string reversed.
   - Handles multi-word strings, palindromes, punctuation, and non-string inputs.

3. **`calculator`**
   - Object containing basic arithmetic operations: `add(a, b)`, `subtract(a, b)`, `divide(a, b)`, `multiply(a, b)`.
   - Supports positive numbers, negative numbers, decimals, and division by zero.

4. **`caesarCipher(str, shift)`**
   - Shifts each character by the given shift factor.
   - Wraps from `z` to `a` (and `Z` to `A`).
   - Preserves letter casing.
   - Leaves spaces, punctuation, and non-alphabetical characters untouched.
   - Supports negative shifts, shifts greater than 26, and shift of 0.

5. **`analyzeArray(arr)`**
   - Takes an array of numbers and returns an object containing:
     - `average`
     - `min`
     - `max`
     - `length`
   - Handles positive/negative numbers, single elements, identical elements, and empty/non-array inputs.

## Setup & Running Tests

1. Install dependencies:
   ```bash
   npm install
   ```

2. Run test suites:
   ```bash
   npm test
   ```

3. Run test coverage:
   ```bash
   npm run coverage
   ```
