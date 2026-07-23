# moonforce

A MoonBit port of [d3-force](https://github.com/d3/d3-force) — force-directed graph layout using velocity Verlet integration.

## Overview

**moonforce** brings the classic D3.js force simulation to the MoonBit ecosystem. It computes aesthetic, readable network layouts by simulating physical forces on graph nodes. Zero dependencies, deterministic output, pure computation.

Use cases:
- Network visualization (social graphs, dependency trees)
- Hierarchy exploration
- Bubble charts and cluster layouts
- Any graph that needs automated spatial arrangement

## Features

- All 7 d3-force force types: center, collide, link, manyBody, x, y, radial
- Barnes-Hut approximated N-body simulation via quadtree
- Deterministic output (LCG random source with fixed seed)
- Configurable force parameters (strength, distance, theta, iterations)
- Fixed-position nodes (drag simulation support)
- Node finder (nearest-neighbor search)
- Zero dependencies, platform-independent

## Installation

```bash
moon add Kai-Junhan/moonforce
```

## Quick Start

```moonbit nocheck
///|
fn main {
  // Create nodes
  let nodes = Array::new()
  for i = 0; i < 6; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }

  // Define edges
  let edges = [(0, 1), (0, 2), (1, 3), (2, 4), (3, 5)]

  // Create simulation with forces
  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body())
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.add_force("link", @moonforce.force_link(edges))
  sim.init_forces()

  // Run to convergence
  sim.run()

  // Read final positions
  for i = 0; i < nodes.length(); i = i + 1 {
    println(
      "Node " +
      i.to_string() +
      ": (" +
      nodes[i].x.to_string() +
      ", " +
      nodes[i].y.to_string() +
      ")",
    )
  }
}
```

See `cmd/main/main.mbt` for a complete runnable example.

## API Reference

### Node

```moonbit nocheck
// Create nodes
let n = @moonforce.Node::new_node()          // default (NaN position, auto-placed)
let n = @moonforce.Node::make(x=10.0, y=20.0) // specific position
let n = @moonforce.Node::fixed(x=5.0, y=5.0)  // fixed position (won't move)

// Fix/unfix at runtime
n.fix(50.0, 60.0)   // pin node to (50, 60)
n.unfix()            // release node
```

### Simulation

```moonbit nocheck
let sim = @moonforce.Simulation::new(nodes)

// Add forces
sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
sim.add_force("charge", @moonforce.force_many_body())
sim.add_force("link", @moonforce.force_link([(0, 1), (1, 2)]))

// Initialize and run
sim.init_forces()
sim.run()            // run to convergence

// Or step manually
sim.tick(1)          // single iteration

// Query
let nearest = sim.find(x, y, radius)  // find nearest node
let a = sim.get_alpha()                // current alpha
```

### Forces

| Force | Constructor | Description |
|-------|-------------|-------------|
| Center | `force_center(~x, ~y)` | Pulls centroid toward target point |
| Collision | `force_collide(~radius)` | Prevents node overlap |
| Link | `force_link(edges)` | Spring connections between nodes |
| Many-Body | `force_many_body()` | N-body charge (repulsion/attraction) |
| X | `force_x(~x)` | Pushes toward target X coordinate |
| Y | `force_y(~y)` | Pushes toward target Y coordinate |
| Radial | `force_radial(~radius, ~x, ~y)` | Pushes toward/away from circle |

Each force has an `_advanced` variant with full parameter control:

```moonbit nocheck
@moonforce.force_many_body_advanced(strength=-50.0, theta=0.5, distance_min=1.0, distance_max=500.0)
@moonforce.force_collide_advanced(radius=10.0, strength=0.8, iterations=3)
@moonforce.force_link_advanced(links)  // uses Link struct with per-link distance/strength
@moonforce.force_x_advanced(x=100.0, strength=0.3)
@moonforce.force_y_advanced(y=100.0, strength=0.3)
@moonforce.force_radial_advanced(radius=80.0, x=0.0, y=0.0, strength=0.5)
@moonforce.force_center_with_strength(x=0.0, y=0.0, strength=0.5)
```

### Link

```moonbit nocheck
///|
let link = @moonforce.Link::make(0, 1) // default distance 30

///|
let link = @moonforce.Link::with_distance(0, 1, 50.0) // custom distance
```

## Running the Demo

```bash
moon run cmd/main
```

## Running Tests

```bash
moon test
```

## Project Structure

```
moonforce/
+-- moon.mod                 # Module definition
+-- moon.pkg                 # Root package config
+-- moonforce.mbt            # Core types (Node, ForceConfig)
+-- simulation.mbt           # Simulation engine
+-- quadtree.mbt             # Spatial indexing
+-- lcg.mbt                  # Deterministic random source
+-- force_center.mbt         # Center force
+-- force_collide.mbt        # Collision force
+-- force_link.mbt           # Link/spring force
+-- force_many_body.mbt      # N-body charge force
+-- force_x.mbt              # X-axis positioning
+-- force_y.mbt              # Y-axis positioning
+-- force_radial.mbt         # Radial positioning
+-- moonforce_test.mbt       # Blackbox tests
+-- moonforce_wbtest.mbt     # Whitebox tests
+-- cmd/main/                # Runnable demo
+-- PORTING.md               # Porting documentation
+-- CHANGELOG.md             # Version history
+-- LICENSE                   # Apache-2.0 + ISC attribution
```

## Porting Information

This is a port of **d3-force v3.0.0** (ISC license, Mike Bostock).

- Full porting details: [PORTING.md](PORTING.md)
- Original repository: https://github.com/d3/d3-force
- Ported scope: simulation core + all 7 forces + quadtree + LCG
- Not ported: d3-timer (browser scheduling), DOM rendering, full d3-dispatch

## License

MoonBit port licensed under [Apache-2.0](LICENSE).

The original d3-force algorithm is copyright Mike Bostock, ISC licensed.
See LICENSE for the full ISC copyright notice.
