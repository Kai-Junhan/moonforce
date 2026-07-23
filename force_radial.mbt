///|
/// Force radial: pushes nodes toward or away from a circle of given radius.
/// Ported from d3-force radial.js (ISC license, Mike Bostock).
pub fn force_radial(
  radius? : Double = 0.0,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> ForceConfig {
  let strength = 0.1
  let mut nodes : Array[Node] = Array::new()
  let mut radiuses : Array[Double] = Array::new()
  let mut strengths : Array[Double] = Array::new()

  {
    init: fn(n, _random) {
      nodes = n
      let n_len = n.length()
      radiuses = Array::makei(n_len, fn(_i) { radius })
      strengths = Array::makei(n_len, fn(i) {
        if radiuses[i].is_nan() {
          0.0
        } else {
          strength
        }
      })
    },
    apply: fn(alpha) {
      let n_len = nodes.length()
      for i = 0; i < n_len; i = i + 1 {
        let dx = nodes[i].x - x
        let dy = nodes[i].y - y
        let r = if dx == 0.0 && dy == 0.0 {
          0.000001
        } else {
          (dx * dx + dy * dy).sqrt()
        }
        let k = (radiuses[i] - r) * strengths[i] * alpha / r
        nodes[i].vx = nodes[i].vx + dx * k
        nodes[i].vy = nodes[i].vy + dy * k
      }
    },
  }
}
