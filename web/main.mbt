///|
/// Browser demo: force-directed graph with interactive drag.
/// Pure export architecture — JS reads node state via getter functions.

/// State container
struct State {
  nodes : Array[@moonforce.Node]
  links_src : Array[Int]
  links_tgt : Array[Int]
  mut sim : @moonforce.Simulation?
}

///|
/// Global state held in array slot for mutability.
let state : State = {
  nodes: Array::new(),
  links_src: Array::new(),
  links_tgt: Array::new(),
  sim: None,
}

///|
/// Initialize demo graph: a tree with given node count.
pub fn setup(node_count : Int) -> Unit {
  state.nodes.clear()
  state.links_src.clear()
  state.links_tgt.clear()
  for i = 0; i < node_count; i = i + 1 {
    state.nodes.push(@moonforce.Node::new_node())
  }
  let links = Array::new()
  for i = 1; i < node_count; i = i + 1 {
    state.links_src.push(i / 2)
    state.links_tgt.push(i)
    links.push((i / 2, i))
  }
  let s = @moonforce.Simulation::new(state.nodes)
  s.add_force("charge", @moonforce.force_many_body())
  s.add_force("center", @moonforce.force_center(x=400.0, y=300.0))
  s.add_force("link", @moonforce.force_link(links))
  s.add_force("collide", @moonforce.force_collide(radius=8.0))
  state.sim = Some(s)
}

///|
/// Advance simulation by one tick.
pub fn tick() -> Unit {
  match state.sim {
    Some(s) => s.tick(1)
    None => ()
  }
}

///|
/// Get node count.
pub fn get_node_count() -> Int {
  state.nodes.length()
}

///|
/// Get edge count.
pub fn get_edge_count() -> Int {
  state.links_src.length()
}

///|
/// Get node x position.
pub fn get_node_x(index : Int) -> Double {
  state.nodes[index].x
}

///|
/// Get node y position.
pub fn get_node_y(index : Int) -> Double {
  state.nodes[index].y
}

///|
/// Get edge source node index.
pub fn get_edge_source(index : Int) -> Int {
  state.links_src[index]
}

///|
/// Get edge target node index.
pub fn get_edge_target(index : Int) -> Int {
  state.links_tgt[index]
}

///|
/// Find the nearest node to (x, y) within radius.
pub fn find_node(x : Double, y : Double, radius : Double) -> Int {
  match state.sim {
    Some(s) => s.find(x, y, radius)
    None => -1
  }
}

///|
/// Fix a node at position (used during drag).
pub fn fix_node(index : Int, x : Double, y : Double) -> Unit {
  if index >= 0 && index < state.nodes.length() {
    state.nodes[index].fix(x, y)
  }
}

///|
/// Unfix a node (release after drag).
pub fn unfix_node(index : Int) -> Unit {
  if index >= 0 && index < state.nodes.length() {
    state.nodes[index].unfix()
  }
}

///|
/// Reheat the simulation (restart alpha).
pub fn reheat() -> Unit {
  match state.sim {
    Some(s) => {
      s.set_alpha(0.3)
      s.restart()
    }
    None => ()
  }
}

///|
/// Get current alpha value.
pub fn get_alpha() -> Double {
  match state.sim {
    Some(s) => s.get_alpha()
    None => 0.0
  }
}

///|
fn main {
  setup(25)
}
