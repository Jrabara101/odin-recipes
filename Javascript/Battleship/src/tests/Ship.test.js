import Ship from "../models/Ship";

describe("Ship Factory / Class", () => {
  test("creates a ship with the specified length", () => {
    const ship = new Ship(4);
    expect(ship.length).toBe(4);
  });

  test("initializes with 0 hits", () => {
    const ship = new Ship(3);
    expect(ship.hits).toBe(0);
  });

  test("isSunk() returns false when newly created", () => {
    const ship = new Ship(3);
    expect(ship.isSunk()).toBe(false);
  });

  test("hit() increases the number of hits", () => {
    const ship = new Ship(3);
    ship.hit();
    expect(ship.hits).toBe(1);
    ship.hit();
    expect(ship.hits).toBe(2);
  });

  test("isSunk() returns false if hits are less than length", () => {
    const ship = new Ship(3);
    ship.hit();
    ship.hit();
    expect(ship.isSunk()).toBe(false);
  });

  test("isSunk() returns true when hits equal length", () => {
    const ship = new Ship(3);
    ship.hit();
    ship.hit();
    ship.hit();
    expect(ship.isSunk()).toBe(true);
  });

  test("hit() does not exceed the ship length", () => {
    const ship = new Ship(2);
    ship.hit();
    ship.hit();
    ship.hit(); // Extra hit
    expect(ship.hits).toBe(2);
    expect(ship.isSunk()).toBe(true);
  });

  test("accepts an optional name for identification", () => {
    const ship = new Ship(5, "Carrier");
    expect(ship.name).toBe("Carrier");
  });

  test("throws error if invalid length is provided", () => {
    expect(() => new Ship(0)).toThrow();
    expect(() => new Ship(-2)).toThrow();
    expect(() => new Ship("invalid")).toThrow();
  });
});
