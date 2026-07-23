///|
fn main {
  println("=== Random Graph Layout ===")
  println("")

  // Generate a random graph with 20 nodes and random edges
  let n = 20
  let nodes = Array::new()
  for i = 0; i < n; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }

  // Create edges using a simple deterministic pattern (pseudo-random)
  let edges : Array[(Int, Int)] = Array::new()
  for i = 1; i < n; i = i + 1 {
    // Connect to a "random" earlier node
    let target = (i * 7 + 3) % i
    edges.push((i, target))
  }
  // Add a few cross-edges for density
  edges.push((5, 12))
  edges.push((3, 15))
  edges.push((8, 17))
  edges.push((1, 19))

  println("Nodes: " + n.to_string())
  println("Edges: " + edges.length().to_string())
  println("")

  // Simulate
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body_advanced(strength=-40.0))
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.add_force("link", @moonforce.force_link(edges))
  sim.add_force("collide", @moonforce.force_collide(radius=8.0))
  sim.init_forces()
  sim.run()

  println("Layout complete. Node positions:")
  println("")
  for i = 0; i < n; i = i + 1 {
    let x = (nodes[i].x * 10.0).round() / 10.0
    let y = (nodes[i].y * 10.0).round() / 10.0
    println(
      "  [" + i.to_string() + "] x=" + x.to_string() + " y=" + y.to_string(),
    )
  }

  // Compute some layout metrics
  let mut min_dist = 100000.0
  let mut max_dist = 0.0
  for i = 0; i < n; i = i + 1 {
    for j = i + 1; j < n; j = j + 1 {
      let dx = nodes[i].x - nodes[j].x
      let dy = nodes[i].y - nodes[j].y
      let d = (dx * dx + dy * dy).sqrt()
      if d < min_dist {
        min_dist = d
      }
      if d > max_dist {
        max_dist = d
      }
    }
  }
  println("")
  println(
    "Min pairwise distance: " + ((min_dist * 100.0).round() / 100.0).to_string(),
  )
  println(
    "Max pairwise distance: " + ((max_dist * 100.0).round() / 100.0).to_string(),
  )
}
