///|
/// Quadtree for spatial indexing.
/// Uses struct-of-arrays layout to work with MoonBit's mutable array semantics.
/// Ported from d3-quadtree (ISC license, Mike Bostock).
pub struct QuadTree {
  is_leaf : Array[Bool]
  data : Array[Int]
  nw : Array[Int]
  ne : Array[Int]
  sw : Array[Int]
  se : Array[Int]
  x0 : Array[Double]
  y0 : Array[Double]
  x1 : Array[Double]
  y1 : Array[Double]
  r : Array[Double]
  xc : Array[Double]
  yc : Array[Double]
  value : Array[Double]
  next : Array[Int]
  mut count : Int
  mut root : Int
}

///|
pub fn new_quadtree(capacity : Int) -> QuadTree {
  {
    is_leaf: Array::makei(capacity, fn(_) { true }),
    data: Array::makei(capacity, fn(_) { 0 }),
    nw: Array::makei(capacity, fn(_) { -1 }),
    ne: Array::makei(capacity, fn(_) { -1 }),
    sw: Array::makei(capacity, fn(_) { -1 }),
    se: Array::makei(capacity, fn(_) { -1 }),
    x0: Array::makei(capacity, fn(_) { 0.0 }),
    y0: Array::makei(capacity, fn(_) { 0.0 }),
    x1: Array::makei(capacity, fn(_) { 0.0 }),
    y1: Array::makei(capacity, fn(_) { 0.0 }),
    r: Array::makei(capacity, fn(_) { 0.0 }),
    xc: Array::makei(capacity, fn(_) { 0.0 }),
    yc: Array::makei(capacity, fn(_) { 0.0 }),
    value: Array::makei(capacity, fn(_) { 0.0 }),
    next: Array::makei(capacity, fn(_) { -1 }),
    count: 0,
    root: -1,
  }
}

///|
pub fn build_from_nodes(
  n : Int,
  get_x : (Int) -> Double,
  get_y : (Int) -> Double,
) -> QuadTree {
  let qt = new_quadtree(n * 4 + 10)
  for i = 0; i < n; i = i + 1 {
    add(qt, i, get_x(i), get_y(i))
  }
  qt
}

///|
fn alloc_node(qt : QuadTree) -> Int {
  let idx = qt.count
  qt.count = qt.count + 1
  idx
}

///|
fn set_leaf(
  qt : QuadTree,
  idx : Int,
  data_idx : Int,
  cx : Double,
  cy : Double,
) -> Unit {
  qt.is_leaf[idx] = true
  qt.data[idx] = data_idx
  qt.x0[idx] = cx
  qt.y0[idx] = cy
  qt.x1[idx] = cx
  qt.y1[idx] = cy
  qt.next[idx] = -1
}

///|
fn set_inner(qt : QuadTree, idx : Int) -> Unit {
  qt.is_leaf[idx] = false
  qt.data[idx] = 0
  qt.nw[idx] = -1
  qt.ne[idx] = -1
  qt.sw[idx] = -1
  qt.se[idx] = -1
  qt.next[idx] = -1
}

///|
fn set_leaf_bounds(
  qt : QuadTree,
  idx : Int,
  data_idx : Int,
  x0b : Double,
  y0b : Double,
  x1b : Double,
  y1b : Double,
) -> Unit {
  qt.is_leaf[idx] = true
  qt.data[idx] = data_idx
  qt.x0[idx] = x0b
  qt.y0[idx] = y0b
  qt.x1[idx] = x1b
  qt.y1[idx] = y1b
  qt.next[idx] = -1
}

///|
fn add(qt : QuadTree, data_idx : Int, x : Double, y : Double) -> Unit {
  if qt.root == -1 {
    let idx = alloc_node(qt)
    set_leaf(qt, idx, data_idx, x, y)
    qt.root = idx
    return
  }
  // Extend root bounds if needed
  if x < qt.x0[qt.root] {
    qt.x0[qt.root] = x
  }
  if y < qt.y0[qt.root] {
    qt.y0[qt.root] = y
  }
  if x > qt.x1[qt.root] {
    qt.x1[qt.root] = x
  }
  if y > qt.y1[qt.root] {
    qt.y1[qt.root] = y
  }
  add_loop(qt, qt.root, data_idx, x, y)
}

///|
fn add_loop(
  qt : QuadTree,
  idx : Int,
  data_idx : Int,
  x : Double,
  y : Double,
) -> Unit {
  if qt.is_leaf[idx] {
    let old_data = qt.data[idx]
    let old_x = qt.x0[idx]
    let old_y = qt.y0[idx]
    if x == old_x && y == old_y {
      let new_idx = alloc_node(qt)
      set_leaf(qt, new_idx, data_idx, old_x, old_y)
      qt.next[new_idx] = qt.next[idx]
      qt.next[idx] = new_idx
    } else {
      let x0 = qt.x0[idx]
      let y0 = qt.y0[idx]
      let x1 = qt.x1[idx]
      let y1 = qt.y1[idx]
      let xm = (x0 + x1) / 2.0
      let ym = (y0 + y1) / 2.0
      split_and_add(
        qt, idx, old_data, old_x, old_y, data_idx, x, y, x0, y0, x1, y1, xm, ym,
      )
    }
    return
  }

  let x0 = qt.x0[idx]
  let y0 = qt.y0[idx]
  let x1 = qt.x1[idx]
  let y1 = qt.y1[idx]
  let xm = (x0 + x1) / 2.0
  let ym = (y0 + y1) / 2.0

  let child_idx = if x < xm {
    if y < ym {
      qt.nw[idx]
    } else {
      qt.sw[idx]
    }
  } else if y < ym {
    qt.ne[idx]
  } else {
    qt.se[idx]
  }

  if child_idx == -1 {
    let new_idx = alloc_node(qt)
    let cx0 = if x < xm { x0 } else { xm }
    let cy0 = if y < ym { y0 } else { ym }
    let cx1 = if x < xm { xm } else { x1 }
    let cy1 = if y < ym { ym } else { y1 }
    set_leaf_bounds(qt, new_idx, data_idx, cx0, cy0, cx1, cy1)
    if x < xm {
      if y < ym {
        qt.nw[idx] = new_idx
      } else {
        qt.sw[idx] = new_idx
      }
    } else if y < ym {
      qt.ne[idx] = new_idx
    } else {
      qt.se[idx] = new_idx
    }
  } else {
    add_loop(qt, child_idx, data_idx, x, y)
  }
}

///|
fn split_and_add(
  qt : QuadTree,
  leaf_idx : Int,
  old_data : Int,
  old_x : Double,
  old_y : Double,
  new_data : Int,
  new_x : Double,
  new_y : Double,
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
  xm : Double,
  ym : Double,
) -> Unit {
  set_inner(qt, leaf_idx)

  let old_child = alloc_node(qt)
  let ox0 = if old_x < xm { x0 } else { xm }
  let oy0 = if old_y < ym { y0 } else { ym }
  let ox1 = if old_x < xm { xm } else { x1 }
  let oy1 = if old_y < ym { ym } else { y1 }
  set_leaf_bounds(qt, old_child, old_data, ox0, oy0, ox1, oy1)
  if old_x < xm {
    if old_y < ym {
      qt.nw[leaf_idx] = old_child
    } else {
      qt.sw[leaf_idx] = old_child
    }
  } else if old_y < ym {
    qt.ne[leaf_idx] = old_child
  } else {
    qt.se[leaf_idx] = old_child
  }

  let new_child = alloc_node(qt)
  let nx0 = if new_x < xm { x0 } else { xm }
  let ny0 = if new_y < ym { y0 } else { ym }
  let nx1 = if new_x < xm { xm } else { x1 }
  let ny1 = if new_y < ym { ym } else { y1 }
  set_leaf_bounds(qt, new_child, new_data, nx0, ny0, nx1, ny1)
  if new_x < xm {
    if new_y < ym {
      qt.nw[leaf_idx] = new_child
    } else {
      qt.sw[leaf_idx] = new_child
    }
  } else if new_y < ym {
    qt.ne[leaf_idx] = new_child
  } else {
    qt.se[leaf_idx] = new_child
  }
}

///|
/// Visit nodes in post-order.
pub fn visit_after(qt : QuadTree, f : (QuadTree, Int) -> Unit) -> Unit {
  if qt.root != -1 {
    visit_after_rec(qt, qt.root, f)
  }
}

///|
fn visit_after_rec(
  qt : QuadTree,
  idx : Int,
  f : (QuadTree, Int) -> Unit,
) -> Unit {
  if !qt.is_leaf[idx] {
    if qt.nw[idx] != -1 {
      visit_after_rec(qt, qt.nw[idx], f)
    }
    if qt.ne[idx] != -1 {
      visit_after_rec(qt, qt.ne[idx], f)
    }
    if qt.sw[idx] != -1 {
      visit_after_rec(qt, qt.sw[idx], f)
    }
    if qt.se[idx] != -1 {
      visit_after_rec(qt, qt.se[idx], f)
    }
  }
  f(qt, idx)
}

///|
/// Visit nodes in top-down order. Callback returns `true` to skip a subtree.
pub fn visit(qt : QuadTree, f : (QuadTree, Int) -> Bool) -> Unit {
  if qt.root != -1 {
    visit_rec(qt, qt.root, f)
  }
}

///|
fn visit_rec(qt : QuadTree, idx : Int, f : (QuadTree, Int) -> Bool) -> Unit {
  if f(qt, idx) {
    return
  }
  if !qt.is_leaf[idx] {
    if qt.nw[idx] != -1 {
      visit_rec(qt, qt.nw[idx], f)
    }
    if qt.ne[idx] != -1 {
      visit_rec(qt, qt.ne[idx], f)
    }
    if qt.sw[idx] != -1 {
      visit_rec(qt, qt.sw[idx], f)
    }
    if qt.se[idx] != -1 {
      visit_rec(qt, qt.se[idx], f)
    }
  }
}

///|
/// Find nearest node to (x, y) within radius squared.
/// Returns node index, or -1 if none found.
pub fn find(qt : QuadTree, x : Double, y : Double, radius2 : Double) -> Int {
  // Simplified: linear scan over all leaves
  // Full quadtree-based nearest search can be added later
  let mut best_idx = -1
  let mut best_d2 = radius2
  let n = qt.count
  for i = 0; i < n; i = i + 1 {
    if qt.is_leaf[i] {
      let mut idx = i
      while idx != -1 {
        let dx = x - qt.x0[idx]
        let dy = y - qt.y0[idx]
        let d2 = dx * dx + dy * dy
        if d2 < best_d2 {
          best_d2 = d2
          best_idx = qt.data[idx]
        }
        idx = qt.next[idx]
      }
    }
  }
  best_idx
}
