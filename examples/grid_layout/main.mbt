///|
fn main {
  println("=== Grid Graph Layout Demo ===")
  println("")
  println("Lays out a 5x5 grid graph using link + charge + centering forces.")
  println("")

  let rows = 5
  let cols = 5
  let n = rows * cols
  let nodes = Array::new()
  for i = 0; i < n; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }

  // Grid edges: horizontal + vertical adjacency
  let edges : Array[(Int, Int)] = Array::new()
  for r = 0; r < rows; r = r + 1 {
    for c = 0; c < cols; c = c + 1 {
      let idx = r * cols + c
      if c + 1 < cols {
        edges.push((idx, idx + 1))
      }
      if r + 1 < rows {
        edges.push((idx, idx + cols))
      }
    }
  }

  println(
    "Grid: " +
    rows.to_string() +
    "x" +
    cols.to_string() +
    " = " +
    n.to_string() +
    " nodes",
  )
  println("Edges: " + edges.length().to_string())
  println("")

  let links = Array::makei(edges.length(), fn(i) {
    let (s, t) = edges[i]
    @moonforce.Link::with_distance(s, t, 40.0)
  })

  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body_advanced(strength=-100.0))
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.add_force("link", @moonforce.force_link_advanced(links))
  sim.add_force("collide", @moonforce.force_collide(radius=15.0))
  sim.init_forces()
  sim.run()

  // Print as grid
  println("Node positions (row, col) -> (x, y):")
  println("")
  for r = 0; r < rows; r = r + 1 {
    let mut line = "  Row " + r.to_string() + ": "
    for c = 0; c < cols; c = c + 1 {
      let idx = r * cols + c
      let x = (nodes[idx].x * 10.0).round() / 10.0
      let y = (nodes[idx].y * 10.0).round() / 10.0
      line = line + "(" + x.to_string() + "," + y.to_string() + ") "
    }
    println(line)
  }

  // Verify structure: adjacent nodes should be closer than non-adjacent
  let mut adj_dist_sum = 0.0
  let mut adj_count = 0
  for i = 0; i < edges.length(); i = i + 1 {
    let (s, t) = edges[i]
    let dx = nodes[s].x - nodes[t].x
    let dy = nodes[s].y - nodes[t].y
    adj_dist_sum = adj_dist_sum + (dx * dx + dy * dy).sqrt()
    adj_count = adj_count + 1
  }
  let avg_adj = adj_dist_sum / adj_count.to_double()
  println("")
  println(
    "Average adjacent distance: " +
    ((avg_adj * 10.0).round() / 10.0).to_string(),
  )
}
