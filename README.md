# moonforce

A MoonBit port of [d3-force](https://github.com/d3/d3-force) v3.0.0 — force-directed graph layout using velocity Verlet integration.

[![Build](https://github.com/Kai-Junhan/moonforce/actions/workflows/ci.yml/badge.svg)](https://github.com/Kai-Junhan/moonforce/actions)
[![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg)](LICENSE)

## Overview

**moonforce** brings the D3.js force simulation engine to the MoonBit ecosystem. It computes aesthetic, readable network layouts by simulating physical forces on graph nodes. Zero external dependencies, deterministic output, compiles to WASM-GC.

**Use cases:**
- Network visualization (social graphs, dependency trees, knowledge graphs)
- Hierarchy exploration and tree layouts
- Bubble charts and cluster layouts
- Interactive graph editors with drag support
- Any graph that needs automated spatial arrangement

## Features

- 7 composable force types: center, collide, link, manyBody, x, y, radial
- Barnes-Hut N-body approximation via quadtree (O(N log N))
- Deterministic output (LCG random source with fixed seed)
- Configurable parameters (strength, distance, theta, iterations)
- Fixed-position nodes (pin/unpin for drag interaction)
- Nearest-neighbor search
- WASM-GC target — runs in browser without JS glue
- Zero dependencies beyond `moonbitlang/core`

## Installation

```bash
moon add Kai-Junhan/moonforce
```

## Quick Start

```moonbit
fn main {
  let nodes = Array::new()
  for i = 0; i < 6; i = i + 1 {
    nodes.push(@moonforce.Node::new_node())
  }

  let edges = [(0, 1), (0, 2), (1, 3), (2, 4), (3, 5)]

  let sim = @moonforce.Simulation::new(nodes)
  sim.add_force("charge", @moonforce.force_many_body())
  sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
  sim.add_force("link", @moonforce.force_link(edges))

  sim.run()

  for i = 0; i < nodes.length(); i = i + 1 {
    println("Node " + i.to_string() + ": (" +
      nodes[i].x.to_string() + ", " + nodes[i].y.to_string() + ")")
  }
}
```

## API Reference

### Node

```moonbit
let n = @moonforce.Node::new_node()            // auto-placed via phyllotaxis
let n = @moonforce.Node::make(x=10.0, y=20.0)  // specific position
let n = @moonforce.Node::fixed(x=5.0, y=5.0)   // fixed (won't move)

n.fix(50.0, 60.0)   // pin node at runtime
n.unfix()            // release node
```

### Simulation

```moonbit
let sim = @moonforce.Simulation::new(nodes)

sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
sim.add_force("charge", @moonforce.force_many_body())
sim.add_force("link", @moonforce.force_link([(0, 1), (1, 2)]))

sim.run()                          // run to convergence
sim.tick(1)                        // single iteration
sim.restart()                      // reset alpha, re-run

let nearest = sim.find(x, y, radius)  // nearest node
let alpha = sim.get_alpha()            // current alpha
```

### Forces

| Force | Constructor | Description |
|-------|-------------|-------------|
| Center | `force_center(x?, y?)` | Pulls centroid toward target point |
| Collision | `force_collide(radius?)` | Prevents node overlap |
| Link | `force_link(edges)` | Spring connections between nodes |
| Many-Body | `force_many_body()` | N-body charge (repulsion default) |
| X | `force_x(x?)` | Pushes toward target X coordinate |
| Y | `force_y(y?)` | Pushes toward target Y coordinate |
| Radial | `force_radial(radius?, x?, y?)` | Constrains to circle |

Each force has an `_advanced` variant with full parameter control:

```moonbit
@moonforce.force_many_body_advanced(strength=-50.0, theta=0.5,
  distance_min=1.0, distance_max=500.0)
@moonforce.force_collide_advanced(radius=10.0, strength=0.8, iterations=3)
@moonforce.force_link_advanced(links)  // Link struct with per-link config
@moonforce.force_x_advanced(x=100.0, strength=0.3)
@moonforce.force_y_advanced(y=100.0, strength=0.3)
@moonforce.force_radial_advanced(radius=80.0, x=0.0, y=0.0, strength=0.5)
@moonforce.force_center_with_strength(x=0.0, y=0.0, strength=0.5)
```

### Link

```moonbit
let link = @moonforce.Link::make(0, 1)               // default distance 30
let link = @moonforce.Link::with_distance(0, 1, 50.0) // custom distance
```

## Examples

Five complete example programs are included:

| Example | Description |
|---------|-------------|
| `examples/random_graph/` | Random graph with charge + center |
| `examples/tree_layout/` | Tree hierarchy layout |
| `examples/radial_layout/` | Radial constraint layout |
| `examples/grid_layout/` | Grid with positioning forces |
| `examples/cluster/` | Multi-cluster with radial separation |

Run any example:

```bash
moon run examples/random_graph
```

## Browser Demo

An interactive browser demo with drag interaction is available in `web/`:

```bash
moon build --target wasm-gc
# Serve web/ directory with any HTTP server
```

## Running Tests

```bash
moon test              # run all 60 tests
moon check             # type check
moon build --target wasm-gc  # build WASM
```

## Project Structure

```
moonforce/
├── moonforce.mbt          # Core types (Node, ForceConfig)
├── simulation.mbt         # Simulation engine (Verlet integrator)
├── quadtree.mbt           # Barnes-Hut spatial index
├── lcg.mbt                # Deterministic LCG random
├── force_center.mbt       # Center force
├── force_collide.mbt      # Collision detection force
├── force_link.mbt         # Spring/link force
├── force_many_body.mbt    # N-body charge force
├── force_x.mbt            # X-positioning force
├── force_y.mbt            # Y-positioning force
├── force_radial.mbt       # Radial constraint force
├── moonforce_test.mbt     # 34 blackbox tests
├── moonforce_wbtest.mbt   # 22 whitebox tests
├── cmd/main/              # CLI demo
├── web/                   # Browser interactive demo
├── examples/              # 5 example programs
├── PORTING.md             # Porting documentation
└── CHANGELOG.md           # Version history
```

## Porting from d3-force

This is a faithful port of **d3-force v3.0.0** (ISC license, Mike Bostock).

Key adaptations for MoonBit:
- Struct-of-arrays quadtree (vs JS object tree)
- `ForceConfig { init, apply }` closures (vs prototype methods)
- 32-bit integer LCG (vs JS `| 0` bitwise truncation)
- Labeled parameters (vs d3 method chaining)
- No DOM/timer dependency — pure computation engine

See [PORTING.md](PORTING.md) for detailed mapping.

## License

ISC License. See [LICENSE](LICENSE).

Original d3-force algorithm copyright Mike Bostock (ISC).

