///|
/// Force simulation engine — the core of d3-force port.
/// Ported from d3-force simulation.js (ISC license, Mike Bostock).
/// Manages nodes, alpha decay, force iteration, and event dispatch.

///|
/// Initial radius and angle for phyllotaxis (golden-angle spiral layout).
let initial_radius : Double = 10.0

///|
let pi : Double = 3.141592653589793

///|
let initial_angle : Double = pi * (3.0 - 5.0.sqrt())

///|
/// A named force entry stored in the simulation.
struct NamedForce {
  name : String
  cfg : ForceConfig
}

///|
/// The force simulation.
pub struct Simulation {
  mut nodes : Array[Node]
  mut alpha : Double
  mut alpha_min : Double
  alpha_decay : Double
  mut alpha_target : Double
  mut velocity_decay : Double
  mut forces : Array[NamedForce]
  mut random : () -> Double
  mut on_tick : (Simulation) -> Unit
  mut on_end : (Simulation) -> Unit
  mut ended : Bool
}

///|
/// Create a new simulation with optional initial nodes.
pub fn Simulation::new(nodes : Array[Node]) -> Simulation {
  _initialize_nodes(nodes)
  let rng = lcg()
  {
    nodes,
    alpha: 1.0,
    alpha_min: 0.001,
    alpha_decay: 1.0 - @math.pow(0.001, 1.0 / 300.0),
    alpha_target: 0.0,
    velocity_decay: 0.6,
    forces: Array::new(),
    random: rng,
    on_tick: fn(_) {  },
    on_end: fn(_) {  },
    ended: false,
  }
}

///|
/// Initialize node positions using phyllotaxis layout.
fn _initialize_nodes(nodes : Array[Node]) -> Unit {
  let n = nodes.length()
  for i = 0; i < n; i = i + 1 {
    nodes[i].index = i
    if nodes[i].fx_set {
      nodes[i].x = nodes[i].fx
    }
    if nodes[i].fy_set {
      nodes[i].y = nodes[i].fy
    }
    if nodes[i].x.is_nan() || nodes[i].y.is_nan() {
      let radius = initial_radius * (0.5 + i.to_double()).sqrt()
      let angle = i.to_double() * initial_angle
      nodes[i].x = radius * @math.cos(angle)
      nodes[i].y = radius * @math.sin(angle)
    }
    if nodes[i].vx.is_nan() || nodes[i].vy.is_nan() {
      nodes[i].vx = 0.0
      nodes[i].vy = 0.0
    }
  }
}

///|
/// Add or replace a named force.
pub fn Simulation::add_force(
  self : Simulation,
  name : String,
  cfg : ForceConfig,
) -> Unit {
  let n = self.forces.length()
  for i = 0; i < n; i = i + 1 {
    if self.forces[i].name == name {
      self.forces[i] = { name, cfg }
      (cfg.init)(self.nodes, self.random)
      return
    }
  }
  self.forces.push({ name, cfg })
  (cfg.init)(self.nodes, self.random)
}

///|
/// Remove a force by name.
pub fn Simulation::remove_force(self : Simulation, name : String) -> Unit {
  let kept = Array::new()
  let n = self.forces.length()
  for i = 0; i < n; i = i + 1 {
    if self.forces[i].name != name {
      kept.push(self.forces[i])
    }
  }
  self.forces = kept
}

///|
/// Step the simulation by one or more iterations.
pub fn Simulation::tick(self : Simulation, iterations : Int) -> Unit {
  let n = self.nodes.length()
  for k = 0; k < iterations; k = k + 1 {
    self.alpha = self.alpha +
      (self.alpha_target - self.alpha) * self.alpha_decay

    // Apply all forces
    let nf = self.forces.length()
    for f_idx = 0; f_idx < nf; f_idx = f_idx + 1 {
      (self.forces[f_idx].cfg.apply)(self.alpha)
    }

    // Update positions
    for i = 0; i < n; i = i + 1 {
      if self.nodes[i].fx_set {
        self.nodes[i].x = self.nodes[i].fx
        self.nodes[i].vx = 0.0
      } else {
        self.nodes[i].x = self.nodes[i].x + self.nodes[i].vx
        self.nodes[i].vx = self.nodes[i].vx * self.velocity_decay
      }

      if self.nodes[i].fy_set {
        self.nodes[i].y = self.nodes[i].fy
        self.nodes[i].vy = 0.0
      } else {
        self.nodes[i].y = self.nodes[i].y + self.nodes[i].vy
        self.nodes[i].vy = self.nodes[i].vy * self.velocity_decay
      }

      // Recheck after potential fix position
      if self.nodes[i].fx_set {
        self.nodes[i].x = self.nodes[i].fx
      }
      if self.nodes[i].fy_set {
        self.nodes[i].y = self.nodes[i].fy
      }
    }

    // End condition
    if self.alpha < self.alpha_min && !self.ended {
      self.ended = true
      (self.on_end)(self)
    }
  }
  (self.on_tick)(self)
}

///|
/// Toggle the on_tick callback.
pub fn Simulation::set_on_tick(
  self : Simulation,
  f : (Simulation) -> Unit,
) -> Unit {
  self.on_tick = f
}

///|
/// Toggle the on_end callback.  
pub fn Simulation::set_on_end(
  self : Simulation,
  f : (Simulation) -> Unit,
) -> Unit {
  self.on_end = f
}

///|
/// Restart the simulation from alpha = 1.
pub fn Simulation::restart(self : Simulation) -> Unit {
  self.alpha = 1.0
  self.ended = false
}

///|
/// Replace nodes and reinitialize.
pub fn Simulation::reset_nodes(self : Simulation, nodes : Array[Node]) -> Unit {
  self.nodes = nodes
  _initialize_nodes(nodes)
  let n = self.forces.length()
  for i = 0; i < n; i = i + 1 {
    (self.forces[i].cfg.init)(nodes, self.random)
  }
}

///|
/// Set random source and reinitialize all forces.
pub fn Simulation::set_random(self : Simulation, rng : () -> Double) -> Unit {
  self.random = rng
  let n = self.forces.length()
  for i = 0; i < n; i = i + 1 {
    (self.forces[i].cfg.init)(self.nodes, rng)
  }
}

///|
pub fn Simulation::set_velocity_decay_d3(self : Simulation, v : Double) -> Unit {
  self.velocity_decay = 1.0 - v
}

///|
pub fn Simulation::get_alpha(self : Simulation) -> Double {
  self.alpha
}

///|
pub fn Simulation::set_alpha(self : Simulation, a : Double) -> Unit {
  self.alpha = a
}

///|
pub fn Simulation::set_alpha_min(self : Simulation, v : Double) -> Simulation {
  self.alpha_min = v
  self
}

///|
pub fn Simulation::set_alpha_target(
  self : Simulation,
  v : Double,
) -> Simulation {
  self.alpha_target = v
  self
}

///|
pub fn Simulation::get_nodes(self : Simulation) -> Array[Node] {
  self.nodes
}

///|
pub fn Simulation::find(
  self : Simulation,
  x : Double,
  y : Double,
  radius : Double,
) -> Int {
  let n = self.nodes.length()
  let mut best = -1
  let mut best_d2 = radius * radius
  for i = 0; i < n; i = i + 1 {
    let dx = self.nodes[i].x - x
    let dy = self.nodes[i].y - y
    let d2 = dx * dx + dy * dy
    if d2 < best_d2 {
      best_d2 = d2
      best = i
    }
  }
  best
}

///|
pub fn Simulation::run(self : Simulation) -> Unit {
  let max_iterations = 300
  for k = 0; k < max_iterations; k = k + 1 {
    self.tick(1)
    if self.alpha < self.alpha_min {
      break
    }
  }
}

///|
pub fn Simulation::init_forces(self : Simulation) -> Unit {
  let n = self.forces.length()
  for i = 0; i < n; i = i + 1 {
    (self.forces[i].cfg.init)(self.nodes, self.random)
  }
}
