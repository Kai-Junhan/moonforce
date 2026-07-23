///|
/// Linear Congruential Generator (LCG).
/// Ported from d3-force lcg.js (ISC license, Mike Bostock).
/// Uses the same constants as d3-force (from Numerical Recipes).
/// Ensures deterministic, reproducible initial layouts.
///
/// d3 source: s = (a * s + c) | 0; return s / m + 0.5;
/// The `| 0` gives signed 32-bit truncation; `+ 0.5` shifts range to [0, 1).
let lcg_a : Int = 1664525

///|
let lcg_c : Int = 1013904223

///|
let lcg_m : Double = 4294967296.0

///|
pub fn lcg() -> () -> Double {
  let mut s : Int = 1
  fn() -> Double {
    s = lcg_a * s + lcg_c
    s.to_double() / lcg_m + 0.5
  }
}
