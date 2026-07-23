///|
fn main {
  println("=== moonforce demo: force-directed graph layout ===")
  println("")

  // Create a small graph: 8 nodes, 7 edges (tree structure)
  let nodes = Array::new()
  for i = 0; i < 8; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }

  // Tree edges: 0-1, 0-2, 0-3, 1-4, 1-5, 2-6, 3-7
  let links = [(0, 1), (0, 2), (0, 3), (1, 4), (1, 5), (2, 6), (3, 7)]

  println("Graph: 8 nodes, 7 edges (tree)")
  println("Edges: 0-1, 0-2, 0-3, 1-4, 1-5, 2-6, 3-7")
  println("")

  // Build simulation with multiple forces
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body())
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.add_force("link", @moonforce.force_link(links))
  sim.add_force("collide", @moonforce.force_collide(radius=5.0))
  sim.init_forces()

  // Run simulation to convergence
  println("Running simulation...")
  sim.run()
  println("Simulation converged (alpha < alpha_min)")
  println("")

  // Print final node positions
  println("Final node positions:")
  println("  Node |       X |       Y")
  println("  -----|---------|--------")
  for i = 0; i < nodes.length(); i = i + 1 {
    let x_str = format_double(nodes[i].x)
    let y_str = format_double(nodes[i].y)
    let idx_str = i.to_string()
    println("     " + idx_str + " | " + x_str + " | " + y_str)
  }
  println("")

  // Demonstrate find: find nearest node to origin
  let nearest = sim.find(0.0, 0.0, 10000.0)
  println("Nearest node to origin: " + nearest.to_string())
  println("")

  // Demonstrate determinism
  let nodes2 = Array::new()
  for i = 0; i < 8; i = i + 1 {
    nodes2.push(@moonforce.Node::new_node())
  }
  let sim2 = @moonforce.Simulation::new(nodes2)
  sim2.add_force("charge", @moonforce.force_many_body())
  sim2.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim2.add_force("link", @moonforce.force_link(links))
  sim2.add_force("collide", @moonforce.force_collide(radius=5.0))
  sim2.init_forces()
  sim2.run()

  let mut deterministic = true
  for i = 0; i < 8; i = i + 1 {
    if nodes[i].x != nodes2[i].x || nodes[i].y != nodes2[i].y {
      deterministic = false
    }
  }
  if deterministic {
    println("Determinism check: PASS (identical results with same seed)")
  } else {
    println("Determinism check: FAIL")
  }

  println("")
  println("=== Demo complete ===")
}

///|
fn format_double(v : Double) -> String {
  let scaled = (v * 100.0).round() / 100.0
  scaled.to_string()
}
