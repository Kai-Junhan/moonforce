///|
/// Browser demo: force-directed graph visualization.
/// Architecture: MoonBit computes layout, passes data to JS via FFI.

// FFI: call into JavaScript
extern "wasm" fn js_set_graph_size(nodes : Int, edges : Int) = "env" "setGraphSize"

///|
extern "wasm" fn js_set_node(index : Int, x : Double, y : Double) = "env" "setNode"

///|
extern "wasm" fn js_set_edge(index : Int, src : Int, tgt : Int) = "env" "setEdge"

///|
extern "wasm" fn js_render() = "env" "render"

///|
fn main {
  let node_count = 30

  // Create nodes
  let nodes = Array::new()
  for i = 0; i < node_count; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }

  // Build tree edges
  let links = Array::new()
  for i = 1; i < node_count; i = i + 1 {
    links.push((i / 2, i))
  }
  // Add extra cross-edges for visual interest
  links.push((3, 12))
  links.push((5, 18))
  links.push((7, 22))
  links.push((2, 15))
  links.push((9, 25))

  // Run simulation
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body_advanced(strength=-60.0))
  sim.add_force("center", @moonforce.force_center(x=400.0, y=300.0))
  sim.add_force("link", @moonforce.force_link(links))
  sim.add_force("collide", @moonforce.force_collide(radius=12.0))
  sim.run()

  // Pass results to JS
  let edge_count = links.length()
  js_set_graph_size(node_count, edge_count)

  for i = 0; i < node_count; i = i + 1 {
    js_set_node(i, nodes[i].x, nodes[i].y)
  }

  for i = 0; i < edge_count; i = i + 1 {
    let (src, tgt) = links[i]
    js_set_edge(i, src, tgt)
  }

  js_render()
}
