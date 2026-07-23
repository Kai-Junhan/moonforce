///|
/// Force collide: prevents node overlap using collision detection.
/// Uses quadtree for efficient collision detection.
/// Ported from d3-force collide.js (ISC license, Mike Bostock).

///|
pub fn force_collide(radius? : Double = 1.0) -> ForceConfig {
  force_collide_advanced(radius~, strength=1.0, iterations=1)
}

///|
pub fn force_collide_advanced(
  radius? : Double = 1.0,
  strength? : Double = 1.0,
  iterations? : Int = 1,
) -> ForceConfig {
  let radius_val = radius
  let strength_val = strength
  let iterations_val = iterations
  let mut nodes : Array[Node] = Array::new()
  let mut radii : Array[Double] = Array::new()
  let mut rng : () -> Double = fn() -> Double { 0.0 }

  {
    init: fn(n, random) {
      nodes = n
      rng = random
      let n_len = n.length()
      radii = Array::makei(n_len, fn(_i) { radius_val })
    },
    apply: fn(_alpha) {
      let n_len = nodes.length()
      if n_len == 0 {
        return
      }
      for k = 0; k < iterations_val; k = k + 1 {
        let qt = build_from_nodes(n_len, fn(i) { nodes[i].x + nodes[i].vx }, fn(
          i,
        ) {
          nodes[i].y + nodes[i].vy
        })

        visit_after(qt, fn(qt2, idx) {
          if qt2.is_leaf[idx] {
            let data_idx = qt2.data[idx]
            qt2.r[idx] = radii[data_idx]
            let mut cur = qt2.next[idx]
            while cur != -1 {
              let rv = radii[qt2.data[cur]]
              if rv > qt2.r[idx] {
                qt2.r[idx] = rv
              }
              cur = qt2.next[cur]
            }
          } else {
            let mut max_r = 0.0
            let nw = qt2.nw[idx]
            let ne = qt2.ne[idx]
            let sw = qt2.sw[idx]
            let se = qt2.se[idx]
            if nw != -1 && qt2.r[nw] > max_r {
              max_r = qt2.r[nw]
            }
            if ne != -1 && qt2.r[ne] > max_r {
              max_r = qt2.r[ne]
            }
            if sw != -1 && qt2.r[sw] > max_r {
              max_r = qt2.r[sw]
            }
            if se != -1 && qt2.r[se] > max_r {
              max_r = qt2.r[se]
            }
            qt2.r[idx] = max_r
          }
        })

        for i = 0; i < n_len; i = i + 1 {
          let node_ri = radii[i]
          let node_ri2 = node_ri * node_ri
          let xi = nodes[i].x + nodes[i].vx
          let yi = nodes[i].y + nodes[i].vy
          let ni = i

          visit(qt, fn(qt2, qidx) -> Bool {
            if qt2.is_leaf[qidx] {
              let data_idx = qt2.data[qidx]
              if data_idx <= ni {
                return true
              }

              let r = node_ri + qt2.r[qidx]
              let mut lx = xi - nodes[data_idx].x - nodes[data_idx].vx
              let mut ly = yi - nodes[data_idx].y - nodes[data_idx].vy
              let mut l2 = lx * lx + ly * ly
              if lx == 0.0 {
                lx = (rng() - 0.5) * 0.000001
                l2 = l2 + lx * lx
              }
              if ly == 0.0 {
                ly = (rng() - 0.5) * 0.000001
                l2 = l2 + ly * ly
              }
              if l2 < r * r {
                let l_sqrt = l2.sqrt()
                let k = (r - l_sqrt) / l_sqrt * strength_val
                let rj2 = qt2.r[qidx] * qt2.r[qidx]
                let rr = rj2 / (node_ri2 + rj2)
                nodes[ni].vx = nodes[ni].vx + lx * k * rr
                nodes[ni].vy = nodes[ni].vy + ly * k * rr
                nodes[data_idx].vx = nodes[data_idx].vx - lx * k * (1.0 - rr)
                nodes[data_idx].vy = nodes[data_idx].vy - ly * k * (1.0 - rr)
              }
              return true
            }
            let r2 = node_ri + qt2.r[qidx]
            if qt2.x1[qidx] < xi - r2 || qt2.x0[qidx] > xi + r2 {
              return true
            }
            if qt2.y1[qidx] < yi - r2 || qt2.y0[qidx] > yi + r2 {
              return true
            }
            return false
          })
        }
      }
    },
  }
}
