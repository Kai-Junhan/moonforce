///|
/// Force many-body: N-body charge simulation using Barnes-Hut approximation.
/// Ported from d3-force manyBody.js (ISC license, Mike Bostock).
pub fn force_many_body() -> ForceConfig {
  let mut nodes : Array[Node] = Array::new()
  let mut strengths : Array[Double] = Array::new()
  let mut rng : () -> Double = fn() -> Double { 0.0 }
  let mut alpha_val : Double = 0.0
  let strength_fn_val : Double = -30.0
  let distance_min2 : Double = 1.0
  let distance_max2 : Double = 1000000000000.0
  let theta2 : Double = 0.81

  {
    init: fn(n, random) {
      nodes = n
      rng = random
      let n_len = n.length()
      strengths = Array::makei(n_len, fn(_) { strength_fn_val })
    },
    apply: fn(alpha) {
      let n_len = nodes.length()
      if n_len == 0 {
        return
      }
      alpha_val = alpha

      let qt = build_from_nodes(n_len, fn(i) { nodes[i].x }, fn(i) {
        nodes[i].y
      })

      // Post-order: accumulate strength and center-of-mass for each quad node
      visit_after(qt, fn(qt2, idx) {
        if qt2.is_leaf[idx] {
          let data_idx = qt2.data[idx]
          let mut strength_val = strengths[data_idx]
          let mut cur = qt2.next[idx]
          while cur != -1 {
            strength_val = strength_val + strengths[qt2.data[cur]]
            cur = qt2.next[cur]
          }
          qt2.value[idx] = strength_val
          qt2.xc[idx] = qt2.x0[idx]
          qt2.yc[idx] = qt2.y0[idx]
        } else {
          let mut total_strength = 0.0
          let mut total_weight = 0.0
          let mut mean_x = 0.0
          let mut mean_y = 0.0
          let nw = qt2.nw[idx]
          let ne = qt2.ne[idx]
          let sw = qt2.sw[idx]
          let se = qt2.se[idx]

          if nw != -1 {
            let w = qt2.value[nw].abs()
            total_strength = total_strength + qt2.value[nw]
            total_weight = total_weight + w
            mean_x = mean_x + w * qt2.xc[nw]
            mean_y = mean_y + w * qt2.yc[nw]
          }
          if ne != -1 {
            let w = qt2.value[ne].abs()
            total_strength = total_strength + qt2.value[ne]
            total_weight = total_weight + w
            mean_x = mean_x + w * qt2.xc[ne]
            mean_y = mean_y + w * qt2.yc[ne]
          }
          if sw != -1 {
            let w = qt2.value[sw].abs()
            total_strength = total_strength + qt2.value[sw]
            total_weight = total_weight + w
            mean_x = mean_x + w * qt2.xc[sw]
            mean_y = mean_y + w * qt2.yc[sw]
          }
          if se != -1 {
            let w = qt2.value[se].abs()
            total_strength = total_strength + qt2.value[se]
            total_weight = total_weight + w
            mean_x = mean_x + w * qt2.xc[se]
            mean_y = mean_y + w * qt2.yc[se]
          }
          qt2.value[idx] = total_strength
          if total_weight > 0.0 {
            qt2.xc[idx] = mean_x / total_weight
            qt2.yc[idx] = mean_y / total_weight
          } else {
            qt2.xc[idx] = qt2.x0[idx]
            qt2.yc[idx] = qt2.y0[idx]
          }
        }
      })

      // Visit: apply forces with Barnes-Hut approximation
      for i = 0; i < n_len; i = i + 1 {
        let node_x = nodes[i].x
        let node_y = nodes[i].y

        visit(qt, fn(qt2, idx) -> Bool {
          if qt2.value[idx] == 0.0 {
            return true
          }
          let qx = qt2.xc[idx] - node_x
          let qy = qt2.yc[idx] - node_y
          let l = qx * qx + qy * qy
          let w = qt2.x1[idx] - qt2.x0[idx]

          // Barnes-Hut condition
          if w * w / theta2 < l {
            if l < distance_max2 {
              let mut qqx = qx
              let mut qqy = qy
              let mut ll = l
              if qqx == 0.0 {
                qqx = (rng() - 0.5) * 0.000001
                ll = ll + qqx * qqx
              }
              if qqy == 0.0 {
                qqy = (rng() - 0.5) * 0.000001
                ll = ll + qqy * qqy
              }
              if ll < distance_min2 {
                ll = (distance_min2 * ll).sqrt()
              }
              let f = qt2.value[idx] * alpha_val / ll
              nodes[i].vx = nodes[i].vx + qqx * f
              nodes[i].vy = nodes[i].vy + qqy * f
            }
            return true
          }

          // Direct leaf processing
          if qt2.is_leaf[idx] || l >= distance_max2 {
            if qt2.is_leaf[idx] {
              let data_idx = qt2.data[idx]
              if data_idx != i || qt2.next[idx] != -1 {
                let mut qqx = qx
                let mut qqy = qy
                let mut ll = l
                if qqx == 0.0 {
                  qqx = (rng() - 0.5) * 0.000001
                  ll = ll + qqx * qqx
                }
                if qqy == 0.0 {
                  qqy = (rng() - 0.5) * 0.000001
                  ll = ll + qqy * qqy
                }
                if ll < distance_min2 {
                  ll = (distance_min2 * ll).sqrt()
                }
                let f = alpha_val / ll

                // Walk coincident list
                let mut cur_idx = idx
                let mut first = true
                while first || cur_idx != idx {
                  first = false
                  if qt2.data[cur_idx] != i {
                    nodes[i].vx = nodes[i].vx +
                      qqx * strengths[qt2.data[cur_idx]] * f
                    nodes[i].vy = nodes[i].vy +
                      qqy * strengths[qt2.data[cur_idx]] * f
                  }
                  if qt2.next[cur_idx] != -1 {
                    cur_idx = qt2.next[cur_idx]
                  } else {
                    break
                  }
                }
              }
            }
            return true
          }

          return false
        })
      }
    },
  }
}
