///|
/// Core types and simulation engine for moonforce.
/// Ported from d3-force v3.0.0 (ISC license, Mike Bostock).

///|
fn make_nan() -> Double {
  0.0 / 0.0
}

///|
pub struct Node {
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  mut fx : Double
  mut fx_set : Bool
  mut fy : Double
  mut fy_set : Bool
  mut index : Int
}

///|
pub fn Node::new_node() -> Node {
  {
    x: make_nan(),
    y: make_nan(),
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
pub fn Node::make(x? : Double = 0.0, y? : Double = 0.0) -> Node {
  {
    x,
    y,
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
pub fn Node::fixed(x? : Double = 0.0, y? : Double = 0.0) -> Node {
  { x, y, vx: 0.0, vy: 0.0, fx: x, fx_set: true, fy: y, fy_set: true, index: 0 }
}

///|
pub fn Node::fix(self : Node, x : Double, y : Double) -> Unit {
  self.fx = x
  self.fx_set = true
  self.fy = y
  self.fy_set = true
}

///|
pub fn Node::unfix(self : Node) -> Unit {
  self.fx_set = false
  self.fy_set = false
}

///|
pub struct ForceConfig {
  init : (Array[Node], () -> Double) -> Unit
  apply : (Double) -> Unit
}
