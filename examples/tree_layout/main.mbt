///|
fn main {
  println("=== Tree Layout Demo ===")
  println("")
  println("Lays out a binary tree (depth=4, 15 nodes) using force simulation.")
  println("")

  // Binary tree: node i has children 2i+1, 2i+2
  let depth = 4
  let n = (1 << depth) - 1 // 15 nodes
  let nodes = Array::new()
  for i = 0; i < n; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }

  // Edges follow binary tree structure
  let edges : Array[(Int, Int)] = Array::new()
  for i = 0; i < n; i = i + 1 {
    let left = 2 * i + 1
    let right = 2 * i + 2
    if left < n {
      edges.push((i, left))
    }
    if right < n {
      edges.push((i, right))
    }
  }

  println("Nodes: " + n.to_string())
  println("Edges: " + edges.length().to_string())
  println("")

  // Fix root at top center
  nodes[0].fix(0.0, -100.0)

  // Simulation with link force and downward bias
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body_advanced(strength=-60.0))
  sim.add_force("link", @moonforce.force_link(edges))
  sim.add_force("collide", @moonforce.force_collide(radius=12.0))
  sim.add_force("y_pull", @moonforce.force_y(y=50.0))
  sim.init_forces()
  sim.run()

  // Print tree with depth info
  println("Layout result (root fixed at y=-100):")
  println("")
  let mut current_depth = 0
  let mut depth_start = 0
  let mut depth_size = 1
  while depth_start < n {
    let mut line = "  Depth " + current_depth.to_string() + ": "
    let end = if depth_start + depth_size < n {
      depth_start + depth_size
    } else {
      n
    }
    for i = depth_start; i < end; i = i + 1 {
      let x = (nodes[i].x * 10.0).round() / 10.0
      let y = (nodes[i].y * 10.0).round() / 10.0
      line = line +
        "[" +
        i.to_string() +
        "](" +
        x.to_string() +
        "," +
        y.to_string() +
        ") "
    }
    println(line)
    depth_start = depth_start + depth_size
    depth_size = depth_size * 2
    current_depth = current_depth + 1
  }

  // Verify root stayed fixed
  println("")
  println(
    "Root position: (" +
    nodes[0].x.to_string() +
    ", " +
    nodes[0].y.to_string() +
    ")",
  )
  if nodes[0].x == 0.0 && nodes[0].y == -100.0 {
    println("Root correctly stayed fixed.")
  }
}
