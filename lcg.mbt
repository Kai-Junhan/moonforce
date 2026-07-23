///|
/// Linear Congruential Generator (LCG).
/// Uses the same constants as d3-force (from Numerical Recipes).
/// Ensures deterministic, reproducible initial layouts.
let a : Double = 1664525.0

///|
let c : Double = 1013904223.0

///|
let m : Double = 4294967296.0

///|
pub fn lcg() -> () -> Double {
  let mut s = 1.0
  fn() -> Double {
    s = (a * s + c) % m
    s / m
  }
}
