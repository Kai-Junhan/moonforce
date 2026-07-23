///|
/// Force X: pushes nodes toward a specific x-coordinate.
/// Ported from d3-force x.js (ISC license, Mike Bostock).

///|
pub fn force_x(x? : Double = 0.0) -> ForceConfig {
  force_x_advanced(x~, strength=0.1)
}

///|
pub fn force_x_advanced(
  x? : Double = 0.0,
  strength? : Double = 0.1,
) -> ForceConfig {
  let mut nodes : Array[Node] = Array::new()
  let mut xz : Array[Double] = Array::new()
  let mut strengths : Array[Double] = Array::new()

  {
    init: fn(n, _random) {
      nodes = n
      let n_len = n.length()
      xz = Array::makei(n_len, fn(_i) { x })
      strengths = Array::makei(n_len, fn(i) {
        if xz[i].is_nan() {
          0.0
        } else {
          strength
        }
      })
    },
    apply: fn(alpha) {
      let n_len = nodes.length()
      for i = 0; i < n_len; i = i + 1 {
        nodes[i].vx = nodes[i].vx + (xz[i] - nodes[i].x) * strengths[i] * alpha
      }
    },
  }
}
