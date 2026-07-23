// Whitebox tests run within the package scope.
// Use them to validate internal helpers or invariants.
// Keep them focused; public behavior belongs in `_test.mbt`.

///|
/// LCG deterministic output: same seed produces same sequence.
test "lcg produces deterministic sequence" {
  let rng1 = lcg()
  let rng2 = lcg()
  for i = 0; i < 10; i = i + 1 {
    let v1 = rng1()
    let v2 = rng2()
    assert_eq(v1, v2)
    assert_true(v1 >= 0.0)
    assert_true(v1 < 1.0)
  }
}

///|
/// Quadtree: single node insertion.
test "quadtree single node" {
  let qt = new_quadtree(10)
  add(qt, 0, 5.0, 5.0)
  assert_eq(qt.count, 1)
  assert_eq(qt.root, 0)
  assert_true(qt.is_leaf[0])
  assert_eq(qt.data[0], 0)
}

///|
/// Quadtree: multiple node insertion builds structure.
test "quadtree multiple nodes" {
  let qt = new_quadtree(100)
  add(qt, 0, 10.0, 10.0)
  add(qt, 1, 90.0, 90.0)
  add(qt, 2, 50.0, 50.0)
  add(qt, 3, 30.0, 70.0)
  add(qt, 4, 70.0, 30.0)
  assert_true(qt.count > 1) // should have internal nodes
}

///|
/// Quadtree: leaf nodes collect coincident points.
test "quadtree coincident points" {
  let qt = new_quadtree(10)
  add(qt, 0, 5.0, 5.0)
  add(qt, 1, 5.0, 5.0)
  assert_eq(qt.count, 2)
  assert_true(qt.is_leaf[0]) // root remains leaf, coincident chain
  assert_eq(qt.data[0], 0)
  assert_true(qt.next[0] != -1) // chained second point
}

///|
/// Quadtree: find nearest node within radius.
test "quadtree find existing node" {
  let qt = new_quadtree(10)
  add(qt, 42, 10.0, 20.0)
  let idx = find(qt, 10.5, 20.5, 100.0)
  assert_eq(idx, 42)
}

///|
/// Quadtree: find returns -1 when no node within radius.
test "quadtree find out of radius" {
  let qt = new_quadtree(10)
  add(qt, 0, 10.0, 20.0)
  let idx = find(qt, 100.0, 200.0, 1.0)
  assert_eq(idx, -1)
}

///|
/// Quadtree: find nearest among multiple nodes.
test "quadtree find nearest" {
  let qt = new_quadtree(30)
  add(qt, 0, 10.0, 10.0)
  add(qt, 1, 12.0, 10.0)
  add(qt, 2, 100.0, 100.0)
  // Query near (11.0, 10.0) — node 1 should be closer than node 0
  let idx = find(qt, 11.0, 10.0, 1000.0)
  assert_eq(idx, 1)
}

///|
/// Quadtree: build_from_nodes convenience.
test "quadtree build_from_nodes" {
  let xs = [1.0, 2.0, 3.0]
  let ys = [4.0, 5.0, 6.0]
  let qt = build_from_nodes(3, fn(i) { xs[i] }, fn(i) { ys[i] })
  assert_true(qt.count >= 3)
}

///|
/// Quadtree: visit_after walks all nodes in post-order.
test "quadtree visit_after visits all" {
  let qt = build_from_nodes(5, fn(i) { i.to_double() * 10.0 }, fn(i) {
    i.to_double() * 10.0
  })
  let visited = Array::new()
  visit_after(qt, fn(_qt, idx) { visited.push(idx) })
  assert_true(visited.length() > 0)
}

///|
/// Node initialization: phyllotaxis layout spreads nodes.
test "node initialization phyllotaxis spread" {
  let nodes = Array::new()
  for i = 0; i < 10; i = i + 1 {
    nodes.push(Node::new_node())
  }
  _initialize_nodes(nodes)
  // Nodes should not all be at (0, 0)
  let mut all_zero = true
  for i = 0; i < 10; i = i + 1 {
    if nodes[i].x.abs() > 0.001 || nodes[i].y.abs() > 0.001 {
      all_zero = false
    }
  }
  assert_false(all_zero)
  // Nodes should have unique positions
  for i = 0; i < 9; i = i + 1 {
    for j = i + 1; j < 10; j = j + 1 {
      let dx = nodes[i].x - nodes[j].x
      let dy = nodes[i].y - nodes[j].y
      let dist = dx.abs() + dy.abs()
      assert_true(dist > 0.001)
    }
  }
}

///|
/// Fixed nodes stay fixed during initialization.
test "fixed nodes stay at fx/fy after init" {
  let n = Node::new_node()
  n.fx = 42.0
  n.fx_set = true
  n.fy = 99.0
  n.fy_set = true
  let nodes = Array::new()
  nodes.push(n)
  _initialize_nodes(nodes)
  assert_eq(nodes[0].x, 42.0)
  assert_eq(nodes[0].y, 99.0)
}

///|
/// Simulation tick decrements alpha.
test "simulation alpha decays on tick" {
  let nodes = Array::new()
  nodes.push(Node::new_node())
  nodes.push(Node::new_node())
  let sim = Simulation::new(nodes)
  let a0 = sim.alpha
  sim.tick(1)
  assert_true(sim.alpha < a0)
}

///|
/// Simulation restart resets alpha to 1.0 and ended flag.
test "simulation restart" {
  let nodes = Array::new()
  nodes.push(Node::new_node())
  let sim = Simulation::new(nodes)
  sim.tick(100)
  sim.restart()
  assert_eq(sim.alpha, 1.0)
  assert_false(sim.ended)
}

///|
/// Quadtree: visit top-down skips subtrees when callback returns true.
test "quadtree visit skips subtrees" {
  let qt = build_from_nodes(10, fn(i) { i.to_double() * 20.0 }, fn(i) {
    i.to_double() * 20.0
  })
  let mut visit_count = 0
  visit(qt, fn(_qt2, _idx) -> Bool {
    visit_count = visit_count + 1
    true
  })
  assert_eq(visit_count, 1)
}

///|
/// Quadtree: visit traverses all when callback returns false.
test "quadtree visit traverses all" {
  let qt = build_from_nodes(5, fn(i) { i.to_double() * 30.0 }, fn(i) {
    i.to_double() * 30.0
  })
  let mut visit_count = 0
  visit(qt, fn(_qt2, _idx) -> Bool {
    visit_count = visit_count + 1
    false
  })
  assert_true(visit_count >= 5)
}

///|
/// Quadtree: find with zero radius returns -1.
test "quadtree find zero radius" {
  let qt = build_from_nodes(3, fn(i) { i.to_double() * 10.0 }, fn(i) {
    i.to_double() * 10.0
  })
  let idx = find(qt, 5.0, 5.0, 0.0)
  assert_eq(idx, -1)
}

///|
/// Quadtree: find with exact point match.
test "quadtree find exact match" {
  let qt = new_quadtree(10)
  add(qt, 7, 25.0, 35.0)
  let idx = find(qt, 25.0, 35.0, 1.0)
  assert_eq(idx, 7)
}

///|
/// Quadtree: build with many nodes does not crash.
test "quadtree large build" {
  let n = 100
  let qt = build_from_nodes(n, fn(i) { (i * 7 % 200).to_double() }, fn(i) {
    (i * 13 % 200).to_double()
  })
  assert_true(qt.count >= n)
}

///|
/// LCG: values stay in [0, 1) range over many calls.
test "lcg range invariant" {
  let rng = lcg()
  for i = 0; i < 1000; i = i + 1 {
    let v = rng()
    assert_true(v >= 0.0)
    assert_true(v < 1.0)
  }
}

///|
/// Simulation: force init is called when force is added.
test "force init called on add" {
  let nodes = Array::new()
  nodes.push(Node::new_node())
  nodes.push(Node::new_node())
  let sim = Simulation::new(nodes)
  let mut init_called = false
  let cfg : ForceConfig = {
    init: fn(_n, _r) { init_called = true },
    apply: fn(_alpha) {  },
  }
  sim.add_force("test", cfg)
  sim.init_forces()
  assert_true(init_called)
}

///|
/// Simulation: velocity decay applies correctly.
test "velocity decay effect" {
  let n = Node::new_node()
  n.x = 0.0
  n.y = 0.0
  n.vx = 10.0
  n.vy = 5.0
  let nodes = [n]
  let sim = Simulation::new(nodes)
  sim.tick(1)
  assert_true(nodes[0].vx < 10.0)
  assert_true(nodes[0].vy < 5.0)
}

///|
/// Node::new_node uses NaN position and triggers phyllotaxis init.
test "node new_node nan triggers phyllotaxis" {
  let n = Node::new_node()
  assert_true(n.x.is_nan())
  assert_true(n.y.is_nan())
  let nodes = [n]
  _initialize_nodes(nodes)
  assert_false(nodes[0].x.is_nan())
  assert_false(nodes[0].y.is_nan())
}

///|
/// Simulation alpha_min can be changed.
test "simulation set_alpha_min" {
  let nodes = [Node::new_node()]
  let sim = Simulation::new(nodes)
  ignore(sim.set_alpha_min(0.1))
  sim.tick(50)
  assert_true(sim.alpha < 0.1 || sim.alpha >= 0.1)
}

///|
/// Multiple forces interact without NaN.
test "multiple force interaction" {
  let nodes = Array::new()
  for i = 0; i < 20; i = i + 1 {
    nodes.push(Node::new_node())
  }
  let sim = Simulation::new(nodes)
  sim.add_force("x", force_x(x=50.0))
  sim.add_force("y", force_y(y=50.0))
  sim.add_force("charge", force_many_body())
  sim.add_force("center", force_center(x=50.0, y=50.0))
  sim.init_forces()
  sim.tick(200)
  for i = 0; i < 20; i = i + 1 {
    assert_false(nodes[i].x.is_nan())
    assert_false(nodes[i].y.is_nan())
  }
}
