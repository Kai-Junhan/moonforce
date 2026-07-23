///|
/// Force link: spring-like connections between nodes.
/// Ported from d3-force link.js (ISC license, Mike Bostock).
pub fn force_link(links_arr : Array[(Int, Int)]) -> ForceConfig {
  let links : Array[(Int, Int)] = links_arr
  let mut nodes : Array[Node] = Array::new()
  let mut strengths : Array[Double] = Array::new()
  let mut distances : Array[Double] = Array::new()
  let mut bias : Array[Double] = Array::new()
  let mut count : Array[Int] = Array::new()
  let mut rng : () -> Double = fn() -> Double { 0.0 }
  let iterations = 1

  {
    init: fn(n, random) {
      nodes = n
      rng = random
      let m = links.length()
      if m == 0 {
        return
      }
      let n_nodes = n.length()

      count = Array::makei(n_nodes, fn(_) { 0 })
      for i = 0; i < m; i = i + 1 {
        let (s, t) = links[i]
        count[s] = count[s] + 1
        count[t] = count[t] + 1
      }

      bias = Array::makei(m, fn(i) {
        let (s, t) = links[i]
        count[s].to_double() / (count[s] + count[t]).to_double()
      })

      strengths = Array::makei(m, fn(i) {
        let (s, t) = links[i]
        let min_count = if count[s] < count[t] { count[s] } else { count[t] }
        1.0 / min_count.to_double()
      })

      distances = Array::makei(m, fn(_) { 30.0 })
    },
    apply: fn(alpha) {
      let m = links.length()
      if m == 0 {
        return
      }
      for k = 0; k < iterations; k = k + 1 {
        for i = 0; i < m; i = i + 1 {
          let (s, t) = links[i]
          let sn = nodes[s]
          let tn = nodes[t]
          let mut x = tn.x + tn.vx - sn.x - sn.vx
          let mut y = tn.y + tn.vy - sn.y - sn.vy
          if x == 0.0 {
            x = (rng() - 0.5) * 0.000001
          }
          if y == 0.0 {
            y = (rng() - 0.5) * 0.000001
          }
          let l = (x * x + y * y).sqrt()
          let k_l = (l - distances[i]) / l * alpha * strengths[i]
          let dx = x * k_l
          let dy = y * k_l
          let b = bias[i]
          nodes[t].vx = nodes[t].vx - dx * b
          nodes[t].vy = nodes[t].vy - dy * b
          nodes[s].vx = nodes[s].vx + dx * (1.0 - b)
          nodes[s].vy = nodes[s].vy + dy * (1.0 - b)
        }
      }
    },
  }
}
