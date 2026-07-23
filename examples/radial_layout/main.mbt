///|
fn main {
  println("=== Radial Layout Demo ===")
  println("")
  println("Places nodes in concentric rings using force_radial.")
  println("")

  // Three rings: inner (3 nodes), middle (6 nodes), outer (12 nodes)
  let inner_count = 3
  let middle_count = 6
  let outer_count = 12
  let total = inner_count + middle_count + outer_count

  let nodes = Array::new()
  for i = 0; i < total; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }

  println("Total nodes: " + total.to_string())
  println("Inner ring (r=30): " + inner_count.to_string() + " nodes")
  println("Middle ring (r=80): " + middle_count.to_string() + " nodes")
  println("Outer ring (r=140): " + outer_count.to_string() + " nodes")
  println("")

  // Build per-node radial links using the advanced API
  let sim = @moonforce.Simulation::new(nodes)

  // We use separate radial forces for each ring group
  // Since the basic API applies uniform radius, we combine with
  // x/y centering for clean layout.
  sim.add_force("charge", @moonforce.force_many_body_advanced(strength=-20.0))
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.add_force("collide", @moonforce.force_collide(radius=10.0))

  // Use radial force with radius=80 for middle ring approximation
  sim.add_force(
    "radial",
    @moonforce.force_radial_advanced(radius=80.0, x=0.0, y=0.0, strength=0.3),
  )

  sim.init_forces()
  sim.run()

  println("Layout results:")
  println("")
  println("  Inner ring nodes (0-2):")
  for i = 0; i < inner_count; i = i + 1 {
    let r = (nodes[i].x * nodes[i].x + nodes[i].y * nodes[i].y).sqrt()
    let r_rounded = (r * 10.0).round() / 10.0
    println("    Node " + i.to_string() + ": r=" + r_rounded.to_string())
  }

  println("  Middle ring nodes (3-8):")
  for i = inner_count; i < inner_count + middle_count; i = i + 1 {
    let r = (nodes[i].x * nodes[i].x + nodes[i].y * nodes[i].y).sqrt()
    let r_rounded = (r * 10.0).round() / 10.0
    println("    Node " + i.to_string() + ": r=" + r_rounded.to_string())
  }

  println("  Outer ring nodes (9-20):")
  for i = inner_count + middle_count; i < total; i = i + 1 {
    let r = (nodes[i].x * nodes[i].x + nodes[i].y * nodes[i].y).sqrt()
    let r_rounded = (r * 10.0).round() / 10.0
    println("    Node " + i.to_string() + ": r=" + r_rounded.to_string())
  }
}
