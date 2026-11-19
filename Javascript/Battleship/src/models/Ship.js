class Ship {
  constructor(length, name = "Ship") {
    if (typeof length !== "number" || length <= 0) {
      throw new Error("Ship length must be a positive number");
    }
    this.length = length;
    this.name = name;
    this.hits = 0;
  }

  hit() {
    if (this.hits < this.length) {
      this.hits += 1;
    }
    return this.hits;
  }

  isSunk() {
    return this.hits >= this.length;
  }
}

export default Ship;
