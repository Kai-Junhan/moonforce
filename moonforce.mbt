///|
/// Core types and simulation engine for moonforce.
/// All forces are defined in separate files in this package.

///|
/// A node in the force simulation. Nodes are mutated in-place during simulation.
pub struct Node {
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  fx : Double
  fx_set : Bool
  fy : Double
  fy_set : Bool
  mut index : Int
}

///|
/// Initialize a node with default values (origin position, zero velocity).
pub fn Node::new_node() -> Node {
  {
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    fx: 0.0,
    fx_set: false,
    fy: 0.0,
    fy_set: false,
    index: 0,
  }
}

///|
/// A force configuration: initialization callback and force step callback.
pub struct ForceConfig {
  init : (Array[Node], () -> Double) -> Unit
  apply : (Double) -> Unit
}
