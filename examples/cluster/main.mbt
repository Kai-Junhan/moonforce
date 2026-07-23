///|
fn main {
  println("=== Cluster Layout Demo ===")
  println("")
  println("Demonstrates clustering with force_x/force_y pulling groups apart.")
  println("")

  // 3 clusters, 6 nodes each
  let cluster_size = 6
  let cluster_count = 3
  let n = cluster_size * cluster_count

  let nodes = Array::new()
  for i = 0; i < n; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }

  // Intra-cluster edges: fully connected within each cluster
  let edges : Array[(Int, Int)] = Array::new()
  for c = 0; c < cluster_count; c = c + 1 {
    let base = c * cluster_size
    for i = 0; i < cluster_size; i = i + 1 {
      for j = i + 1; j < cluster_size; j = j + 1 {
        edges.push((base + i, base + j))
      }
    }
  }
  // Inter-cluster bridges (one edge per pair)
  edges.push((0, cluster_size))
  edges.push((cluster_size, 2 * cluster_size))
  edges.push((0, 2 * cluster_size))

  println("Nodes: " + n.to_string() + " (3 clusters of 6)")
  println("Edges: " + edges.length().to_string())
  println("")

  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body_advanced(strength=-50.0))
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.add_force("link", @moonforce.force_link(edges))
  sim.add_force("collide", @moonforce.force_collide(radius=8.0))
  sim.init_forces()
  sim.run()

  // Print clusters
  for c = 0; c < cluster_count; c = c + 1 {
    let base = c * cluster_size
    let mut cx = 0.0
    let mut cy = 0.0
    for i = 0; i < cluster_size; i = i + 1 {
      cx = cx + nodes[base + i].x
      cy = cy + nodes[base + i].y
    }
    cx = cx / cluster_size.to_double()
    cy = cy / cluster_size.to_double()
    let cx_r = (cx * 10.0).round() / 10.0
    let cy_r = (cy * 10.0).round() / 10.0
    println(
      "Cluster " +
      c.to_string() +
      " centroid: (" +
      cx_r.to_string() +
      ", " +
      cy_r.to_string() +
      ")",
    )

    for i = 0; i < cluster_size; i = i + 1 {
      let idx = base + i
      let x = (nodes[idx].x * 10.0).round() / 10.0
      let y = (nodes[idx].y * 10.0).round() / 10.0
      println(
        "  Node " +
        idx.to_string() +
        ": (" +
        x.to_string() +
        ", " +
        y.to_string() +
        ")",
      )
    }
    println("")
  }

  // Verify: intra-cluster distances should be smaller than inter-cluster
  let mut intra_sum = 0.0
  let mut intra_count = 0
  for c = 0; c < cluster_count; c = c + 1 {
    let base = c * cluster_size
    for i = 0; i < cluster_size; i = i + 1 {
      for j = i + 1; j < cluster_size; j = j + 1 {
        let dx = nodes[base + i].x - nodes[base + j].x
        let dy = nodes[base + i].y - nodes[base + j].y
        intra_sum = intra_sum + (dx * dx + dy * dy).sqrt()
        intra_count = intra_count + 1
      }
    }
  }
  let avg_intra = intra_sum / intra_count.to_double()

  let mut inter_sum = 0.0
  let mut inter_count = 0
  for c1 = 0; c1 < cluster_count; c1 = c1 + 1 {
    for c2 = c1 + 1; c2 < cluster_count; c2 = c2 + 1 {
      let b1 = c1 * cluster_size
      let b2 = c2 * cluster_size
      let dx = nodes[b1].x - nodes[b2].x
      let dy = nodes[b1].y - nodes[b2].y
      inter_sum = inter_sum + (dx * dx + dy * dy).sqrt()
      inter_count = inter_count + 1
    }
  }
  let avg_inter = inter_sum / inter_count.to_double()

  println(
    "Avg intra-cluster distance: " +
    ((avg_intra * 10.0).round() / 10.0).to_string(),
  )
  println(
    "Avg inter-cluster distance: " +
    ((avg_inter * 10.0).round() / 10.0).to_string(),
  )
  if avg_inter > avg_intra {
    println("Clustering verified: inter > intra")
  }
}
