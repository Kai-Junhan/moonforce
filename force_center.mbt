///|
/// Force center: pulls nodes toward a central position.
/// Ported from d3-force center.js (ISC license, Mike Bostock).

///|
pub fn force_center(x? : Double = 0.0, y? : Double = 0.0) -> ForceConfig {
  force_center_with_strength(x~, y~, strength=1.0)
}

///|
pub fn force_center_with_strength(
  x? : Double = 0.0,
  y? : Double = 0.0,
  strength? : Double = 1.0,
) -> ForceConfig {
  let mut nodes : Array[Node] = Array::new()
  {
    init: fn(n, _random) { nodes = n },
    apply: fn(_alpha) {
      let n_len = nodes.length()
      if n_len == 0 {
        return
      }
      let mut sx = 0.0
      let mut sy = 0.0
      for i = 0; i < n_len; i = i + 1 {
        sx = sx + nodes[i].x
        sy = sy + nodes[i].y
      }
      let dx = (sx / n_len.to_double() - x) * strength
      let dy = (sy / n_len.to_double() - y) * strength
      for i = 0; i < n_len; i = i + 1 {
        nodes[i].x = nodes[i].x - dx
        nodes[i].y = nodes[i].y - dy
      }
    },
  }
}
