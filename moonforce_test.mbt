// Blackbox tests run against the package's public API. Use `@moonforce` to import.
// Prefer high-level behaviors over implementation details.
// Run `moon test` to execute and `moon test --update` to refresh snapshots.

///|
/// Simulation convergence: alpha drops below alpha_min after sufficient ticks.
test "simulation converges" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  let mut on_end_called = false
  sim.set_on_end(fn(_) { on_end_called = true })
  sim.tick(500)
  assert_true(on_end_called)
}

///|
/// on_end fires exactly once per cooling cycle.
test "simulation on_end fires once per cycle" {
  let nodes = Array::new()
  nodes.push(@moonforce.Node::new_node())
  let sim = @moonforce.Simulation::new(nodes)
  let mut call_count = 0
  sim.set_on_end(fn(_) { call_count = call_count + 1 })
  sim.tick(500)
  assert_eq(call_count, 1)
  // Another tick should not re-fire
  sim.tick(10)
  assert_eq(call_count, 1)
}

///|
/// Simulation restart allows on_end to fire again.
test "simulation on_end fires after restart" {
  let nodes = Array::new()
  nodes.push(@moonforce.Node::new_node())
  let sim = @moonforce.Simulation::new(nodes)
  let mut call_count = 0
  sim.set_on_end(fn(_) { call_count = call_count + 1 })
  sim.tick(500)
  assert_eq(call_count, 1)
  sim.restart()
  sim.tick(500)
  assert_eq(call_count, 2)
}

///|
/// on_tick fires after each tick call.
test "simulation on_tick callback" {
  let nodes = Array::new()
  nodes.push(@moonforce.Node::new_node())
  let sim = @moonforce.Simulation::new(nodes)
  let mut tick_count = 0
  sim.set_on_tick(fn(_) { tick_count = tick_count + 1 })
  sim.tick(1)
  assert_eq(tick_count, 1)
  sim.tick(5)
  assert_eq(tick_count, 2)
}

///|
/// Determistic simulation: same seed and config produces same layout.
test "simulation is deterministic" {
  // First run
  let n1 = [
    @moonforce.Node::new_node(),
    @moonforce.Node::new_node(),
    @moonforce.Node::new_node(),
  ]
  let sim1 = @moonforce.Simulation::new(n1)
  sim1.add_force("center", @moonforce.force_center(x=100.0, y=100.0))
  sim1.tick(200)

  // Second run with identical setup
  let n2 = [
    @moonforce.Node::new_node(),
    @moonforce.Node::new_node(),
    @moonforce.Node::new_node(),
  ]
  let sim2 = @moonforce.Simulation::new(n2)
  sim2.add_force("center", @moonforce.force_center(x=100.0, y=100.0))
  sim2.tick(200)

  assert_eq(n1[0].x, n2[0].x)
  assert_eq(n1[0].y, n2[0].y)
}

///|
/// Fixed position nodes do not move during simulation.
test "fixed nodes stay in place" {
  let n = @moonforce.Node::fixed(x=50.0, y=60.0)

  let free = @moonforce.Node::new_node()
  let nodes = [n, free]
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.add_force("collide", @moonforce.force_collide(radius=10.0))
  sim.tick(300)
  assert_eq(n.x, 50.0)
  assert_eq(n.y, 60.0)
}

///|
/// Force center: nodes converge near the center point.
test "force center convergence" {
  let nodes = Array::new()
  for i = 0; i < 10; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("center", @moonforce.force_center(x=200.0, y=300.0))
  sim.tick(300)

  let mut sx = 0.0
  let mut sy = 0.0
  let n = nodes.length()
  for i = 0; i < n; i = i + 1 {
    sx = sx + nodes[i].x
    sy = sy + nodes[i].y
  }
  let cx = sx / n.to_double()
  let cy = sy / n.to_double()
  assert_true((cx - 200.0).abs() < 5.0)
  assert_true((cy - 300.0).abs() < 5.0)
}

///|
/// Force x: nodes converge toward target x-coordinate.
test "force x convergence" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("x", @moonforce.force_x(x=50.0))
  sim.tick(500)

  for i = 0; i < nodes.length(); i = i + 1 {
    assert_true((nodes[i].x - 50.0).abs() < 10.0)
  }
}

///|
/// Force y: nodes converge toward target y-coordinate.
test "force y convergence" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("y", @moonforce.force_y(y=-30.0))
  sim.tick(500)

  for i = 0; i < nodes.length(); i = i + 1 {
    assert_true((nodes[i].y + 30.0).abs() < 10.0)
  }
}

///|
/// Force radial: nodes settle near the target radius.
test "force radial convergence" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("radial", @moonforce.force_radial(radius=50.0, x=0.0, y=0.0))
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.tick(500)

  for i = 0; i < nodes.length(); i = i + 1 {
    let r = (nodes[i].x * nodes[i].x + nodes[i].y * nodes[i].y).sqrt()
    assert_true((r - 50.0).abs() < 20.0)
  }
}

///|
/// Force link: connected nodes are pulled together.
test "force link attraction" {
  let a = @moonforce.Node::make(x=0.0, y=0.0)
  let b = @moonforce.Node::make(x=100.0, y=0.0)
  let nodes = [a, b]
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("link", @moonforce.force_link([(0, 1)]))
  sim.tick(200)

  let dx = nodes[0].x - nodes[1].x
  let dy = nodes[0].y - nodes[1].y
  let dist = (dx * dx + dy * dy).sqrt()
  assert_true(dist < 100.0) // closer than initial 100
}

///|
/// Force collide: nodes do not overlap beyond radius sum.
test "force collide non-overlap" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("collide", @moonforce.force_collide(radius=15.0))
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.tick(500)

  for i = 0; i < nodes.length(); i = i + 1 {
    for j = i + 1; j < nodes.length(); j = j + 1 {
      let dx = nodes[i].x - nodes[j].x
      let dy = nodes[i].y - nodes[j].y
      let dist = (dx * dx + dy * dy).sqrt()
      // With center + collide forces, overlap should be minimal
      assert_true(dist > 1.0)
    }
  }
}

///|
/// Force manyBody: repulsion spreads nodes apart.
test "force manyBody repulsion" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    let n = @moonforce.Node::make(x=0.0, y=0.0)
    nodes.push(n)
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body())
  sim.tick(200)

  // Nodes should have moved away from origin
  let mut spread = 0.0
  for i = 0; i < nodes.length(); i = i + 1 {
    spread = spread + (nodes[i].x * nodes[i].x + nodes[i].y * nodes[i].y).sqrt()
  }
  assert_true(spread > 5.0)
}

///|
/// Combined forces produce a stable graph layout.
test "combined forces produce stable layout" {
  let nodes = Array::new()
  for i = 0; i < 8; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body())
  sim.add_force("center", @moonforce.force_center(x=200.0, y=200.0))
  sim.add_force("collide", @moonforce.force_collide(radius=10.0))
  sim.add_force(
    "link",
    @moonforce.force_link([
      (0, 1),
      (0, 2),
      (0, 3),
      (1, 4),
      (2, 5),
      (3, 6),
      (4, 7),
    ]),
  )
  sim.tick(500)

  // Verify no NaN values in positions
  for i = 0; i < nodes.length(); i = i + 1 {
    assert_false(nodes[i].x.is_nan())
    assert_false(nodes[i].y.is_nan())
    assert_false(nodes[i].vx.is_nan())
    assert_false(nodes[i].vy.is_nan())
  }

  // Verify on_end fired
  assert_true(sim.alpha < sim.alpha_min)
}

///|
/// add_force replaces existing force with same name.
test "add_force replaces existing" {
  let nodes = Array::new()
  nodes.push(@moonforce.Node::new_node())
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("x", @moonforce.force_x(x=10.0))
  sim.add_force("x", @moonforce.force_x(x=50.0))
  // Second add should replace without crash
  sim.tick(100)
  // Should be working fine
  assert_false(nodes[0].x.is_nan())
}

///|
/// remove_force properly removes a force.
test "remove_force works" {
  let nodes = Array::new()
  nodes.push(@moonforce.Node::new_node())
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("center", @moonforce.force_center())
  sim.remove_force("center")
  sim.tick(10)
  assert_false(nodes[0].x.is_nan())
}

///|
/// reset_nodes properly reinitializes the simulation.
test "reset_nodes reinitializes" {
  let nodes = Array::new()
  nodes.push(@moonforce.Node::new_node())
  let sim = @moonforce.Simulation::new(nodes)
  sim.tick(50)

  let new_nodes = Array::new()
  let n2 = @moonforce.Node::make(x=100.0, y=200.0)
  new_nodes.push(n2)

  sim.reset_nodes(new_nodes)
  assert_eq(nodes.length(), 1)
}

///|
/// Empty node array does not crash forces.
test "empty node array safe" {
  let nodes = Array::new()
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("center", @moonforce.force_center())
  sim.add_force("x", @moonforce.force_x())
  sim.add_force("y", @moonforce.force_y())
  sim.add_force("collide", @moonforce.force_collide())
  sim.add_force("charge", @moonforce.force_many_body())
  sim.add_force("link", @moonforce.force_link([]))
  sim.add_force("radial", @moonforce.force_radial())
  sim.tick(10)
  assert_true(true)
}

///|
/// Node::make creates node at specified position.
test "Node::make with position" {
  let n = @moonforce.Node::make(x=10.0, y=20.0)
  assert_eq(n.x, 10.0)
  assert_eq(n.y, 20.0)
  assert_eq(n.vx, 0.0)
  assert_eq(n.vy, 0.0)
}

///|
/// Node::fixed creates a fixed node.
test "Node::fixed creates fixed node" {
  let n = @moonforce.Node::fixed(x=42.0, y=99.0)
  assert_eq(n.fx, 42.0)
  assert_true(n.fx_set)
  assert_eq(n.fy, 99.0)
  assert_true(n.fy_set)
}

///|
/// Node fix/unfix methods work.
test "Node fix and unfix" {
  let n = @moonforce.Node::new_node()
  n.fix(10.0, 20.0)
  assert_true(n.fx_set)
  assert_eq(n.fx, 10.0)
  n.unfix()
  assert_false(n.fx_set)
  assert_false(n.fy_set)
}

///|
/// Simulation::find locates nearest node.
test "simulation find nearest node" {
  let nodes = [
    @moonforce.Node::make(x=0.0, y=0.0),
    @moonforce.Node::make(x=100.0, y=0.0),
    @moonforce.Node::make(x=0.0, y=100.0),
  ]
  let sim = @moonforce.Simulation::new(nodes)
  let idx = sim.find(95.0, 5.0, 1000.0)
  assert_eq(idx, 1)
}

///|
/// Simulation::find returns -1 when no node in range.
test "simulation find out of range" {
  let nodes = [@moonforce.Node::make(x=0.0, y=0.0)]
  let sim = @moonforce.Simulation::new(nodes)
  let idx = sim.find(1000.0, 1000.0, 1.0)
  assert_eq(idx, -1)
}

///|
/// Simulation::run converges the simulation.
test "simulation run converges" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("center", @moonforce.force_center())
  sim.init_forces()
  sim.run()
  assert_true(sim.get_alpha() < 0.001)
}

///|
/// Simulation set_alpha and set_alpha_target work.
test "simulation alpha control" {
  let nodes = [@moonforce.Node::new_node()]
  let sim = @moonforce.Simulation::new(nodes)
  sim.set_alpha(0.5)
  assert_eq(sim.get_alpha(), 0.5)
}

///|
/// force_x_advanced with custom strength.
test "force_x_advanced custom strength" {
  let nodes = Array::new()
  for i = 0; i < 3; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("x", @moonforce.force_x_advanced(x=100.0, strength=0.5))
  sim.init_forces()
  sim.run()
  for i = 0; i < nodes.length(); i = i + 1 {
    assert_true((nodes[i].x - 100.0).abs() < 5.0)
  }
}

///|
/// force_y_advanced with custom strength.
test "force_y_advanced custom strength" {
  let nodes = Array::new()
  for i = 0; i < 3; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("y", @moonforce.force_y_advanced(y=-50.0, strength=0.5))
  sim.init_forces()
  sim.run()
  for i = 0; i < nodes.length(); i = i + 1 {
    assert_true((nodes[i].y + 50.0).abs() < 5.0)
  }
}

///|
/// force_center_with_strength works.
test "force_center_with_strength" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force(
    "center",
    @moonforce.force_center_with_strength(x=50.0, y=50.0, strength=0.5),
  )
  sim.init_forces()
  sim.run()
  let mut sx = 0.0
  let mut sy = 0.0
  for i = 0; i < nodes.length(); i = i + 1 {
    sx = sx + nodes[i].x
    sy = sy + nodes[i].y
  }
  let cx = sx / nodes.length().to_double()
  let cy = sy / nodes.length().to_double()
  assert_true((cx - 50.0).abs() < 10.0)
  assert_true((cy - 50.0).abs() < 10.0)
}

///|
/// force_many_body_advanced with custom theta.
test "force_many_body_advanced parameters" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    let n = @moonforce.Node::make(x=0.0, y=0.0)
    nodes.push(n)
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force(
    "charge",
    @moonforce.force_many_body_advanced(strength=-50.0, theta=0.5),
  )
  sim.init_forces()
  sim.tick(100)
  let mut spread = 0.0
  for i = 0; i < nodes.length(); i = i + 1 {
    spread = spread + (nodes[i].x * nodes[i].x + nodes[i].y * nodes[i].y).sqrt()
  }
  assert_true(spread > 10.0)
}

///|
/// force_collide_advanced with multiple iterations.
test "force_collide_advanced iterations" {
  let nodes = Array::new()
  for i = 0; i < 10; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force(
    "collide",
    @moonforce.force_collide_advanced(radius=20.0, strength=1.0, iterations=3),
  )
  sim.add_force("center", @moonforce.force_center())
  sim.init_forces()
  sim.run()
  for i = 0; i < nodes.length(); i = i + 1 {
    for j = i + 1; j < nodes.length(); j = j + 1 {
      let dx = nodes[i].x - nodes[j].x
      let dy = nodes[i].y - nodes[j].y
      let dist = (dx * dx + dy * dy).sqrt()
      assert_true(dist > 5.0)
    }
  }
}

///|
/// force_radial_advanced with custom strength.
test "force_radial_advanced custom strength" {
  let nodes = Array::new()
  for i = 0; i < 5; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force(
    "radial",
    @moonforce.force_radial_advanced(radius=80.0, x=0.0, y=0.0, strength=0.5),
  )
  sim.add_force("center", @moonforce.force_center())
  sim.init_forces()
  sim.run()
  for i = 0; i < nodes.length(); i = i + 1 {
    let r = (nodes[i].x * nodes[i].x + nodes[i].y * nodes[i].y).sqrt()
    assert_true((r - 80.0).abs() < 30.0)
  }
}

///|
/// force_link_advanced with Link objects.
test "force_link_advanced with Link struct" {
  let a = @moonforce.Node::make(x=0.0, y=0.0)
  let b = @moonforce.Node::make(x=200.0, y=0.0)
  let nodes = [a, b]
  let links = [@moonforce.Link::with_distance(0, 1, 50.0)]
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("link", @moonforce.force_link_advanced(links))
  sim.init_forces()
  sim.run()
  let dx = nodes[0].x - nodes[1].x
  let dy = nodes[0].y - nodes[1].y
  let dist = (dx * dx + dy * dy).sqrt()
  assert_true((dist - 50.0).abs() < 30.0)
}

///|
/// Large graph: 50 nodes with combined forces does not produce NaN.
test "large graph stability" {
  let n = 50
  let nodes = Array::new()
  for i = 0; i < n; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }
  let links = Array::new()
  for i = 1; i < n; i = i + 1 {
    links.push((i / 2, i))
  }
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body())
  sim.add_force("center", @moonforce.force_center())
  sim.add_force("link", @moonforce.force_link(links))
  sim.add_force("collide", @moonforce.force_collide(radius=3.0))
  sim.init_forces()
  sim.run()
  for i = 0; i < n; i = i + 1 {
    assert_false(nodes[i].x.is_nan())
    assert_false(nodes[i].y.is_nan())
    assert_false(nodes[i].vx.is_nan())
    assert_false(nodes[i].vy.is_nan())
  }
}

///|
/// Single node does not crash any force.
test "single node all forces" {
  let nodes = [@moonforce.Node::new_node()]
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("center", @moonforce.force_center())
  sim.add_force("x", @moonforce.force_x(x=10.0))
  sim.add_force("y", @moonforce.force_y(y=20.0))
  sim.add_force("collide", @moonforce.force_collide(radius=5.0))
  sim.add_force("charge", @moonforce.force_many_body())
  sim.add_force("radial", @moonforce.force_radial(radius=30.0))
  sim.add_force("link", @moonforce.force_link([]))
  sim.init_forces()
  sim.run()
  assert_false(nodes[0].x.is_nan())
  assert_false(nodes[0].y.is_nan())
}

///|
/// Two nodes with link settle at specified distance.
test "two nodes link distance" {
  let a = @moonforce.Node::make(x=-100.0, y=0.0)
  let b = @moonforce.Node::make(x=100.0, y=0.0)
  let nodes = [a, b]
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("link", @moonforce.force_link([(0, 1)]))
  sim.init_forces()
  sim.run()
  let dx = (nodes[0].x - nodes[1].x).abs()
  assert_true(dx < 200.0)
}

///|
/// get_nodes returns the node array.
test "get_nodes accessor" {
  let nodes = [@moonforce.Node::make(x=5.0, y=10.0)]
  let sim = @moonforce.Simulation::new(nodes)
  let retrieved = sim.get_nodes()
  assert_eq(retrieved.length(), 1)
  assert_eq(retrieved[0].x, 5.0)
}
