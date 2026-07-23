///|
/// Force Y: pushes nodes toward a specific y-coordinate.
/// Ported from d3-force y.js (ISC license, Mike Bostock).
pub fn force_y(y? : Double = 0.0) -> ForceConfig {
  let strength = 0.1
  let mut nodes : Array[Node] = Array::new()
  let mut yz : Array[Double] = Array::new()
  let mut strengths : Array[Double] = Array::new()

  {
    init: fn(n, _random) {
      nodes = n
      let n_len = n.length()
      yz = Array::makei(n_len, fn(_i) { y })
      strengths = Array::makei(n_len, fn(i) {
        if yz[i].is_nan() {
          0.0
        } else {
          strength
        }
      })
    },
    apply: fn(alpha) {
      let n_len = nodes.length()
      for i = 0; i < n_len; i = i + 1 {
        nodes[i].vy = nodes[i].vy + (yz[i] - nodes[i].y) * strengths[i] * alpha
      }
    },
  }
}
