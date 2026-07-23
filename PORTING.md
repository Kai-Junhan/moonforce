# Porting Documentation

## Original Project

| Item | Detail |
|------|--------|
| Project Name | d3-force |
| Repository | https://github.com/d3/d3-force |
| Version Ported | v3.0.0 (June 2021, API-stable) |
| Original License | ISC (OSI-approved permissive license) |
| Original Authors | Mike Bostock and contributors |
| Ecosystem | JavaScript / D3.js |

## Porting Scope

### Ported Modules

| d3-force Source | moonforce Module | Notes |
|----------------|-----------------|-------|
| `src/simulation.js` | `simulation.mbt` | Velocity Verlet integration, alpha cooling, event dispatch |
| `src/center.js` | `force_center.mbt` | Centering force |
| `src/collide.js` | `force_collide.mbt` | Collision detection using quadtree |
| `src/link.js` | `force_link.mbt` | Spring-like link force |
| `src/manyBody.js` | `force_many_body.mbt` | N-body charge with Barnes-Hut approximation |
| `src/x.js` | `force_x.mbt` | Horizontal positioning force |
| `src/y.js` | `force_y.mbt` | Vertical positioning force |
| `src/radial.js` | `force_radial.mbt` | Radial positioning force |
| `src/lcg.js` | `lcg.mbt` | Deterministic linear congruential generator |
| d3-quadtree (dependency) | `quadtree.mbt` | Spatial indexing for Barnes-Hut and collision |

### Not Ported (Explicitly Excluded)

| Component | Reason |
|-----------|--------|
| d3-timer | Browser animation frame scheduling; moonforce is a pure computation library with no platform dependencies |
| d3-dispatch (full) | Simplified to tick/end callbacks; full event system unnecessary for library use |
| DOM/SVG rendering | Not part of d3-force itself (belongs to d3-selection); demo handles rendering separately |
| forceCollide iteration limiter | d3 uses iteration count internally; moonforce exposes it as a parameter |

## Modifications and Adaptations

### API Style

- **JavaScript**: Chainable getter/setter pattern (`simulation.alpha(0.5)` both gets and sets)
- **MoonBit**: Struct fields with explicit getter/setter methods (`sim.set_alpha(0.5)`, `sim.get_alpha()`)

### Type System

- **JavaScript**: Dynamic objects with arbitrary properties (`node.x`, `node.fx`)
- **MoonBit**: Typed `Node` struct with `mut` fields and explicit `fx_set`/`fy_set` flags instead of null checks

### Node Initialization

- **JavaScript**: Nodes without x/y get positioned using phyllotaxis layout (same in moonforce)
- **MoonBit**: Uses `Double::nan()` as sentinel for "uninitialized position" (matching d3's `undefined` check)

### Random Source

- **JavaScript**: `Math.random()` by default, replaceable via `simulation.randomSource()`
- **MoonBit**: Deterministic LCG by default (matches d3's internal LCG), replaceable via `Simulation::set_random()`

### Quadtree Implementation

- **JavaScript**: Object-based tree with pointer references
- **MoonBit**: Struct-of-arrays layout (`Array[Bool]`, `Array[Int]`, `Array[Double]`) for compatibility with MoonBit's value semantics and performance characteristics

### Force Configuration

- **JavaScript**: Forces are objects with `.force()` and `.initialize()` methods
- **MoonBit**: `ForceConfig` struct with `init` and `apply` function fields

### Link Force

- **JavaScript**: Links reference node objects or indices
- **MoonBit**: Links use integer indices (source, target) with typed `Link` struct supporting configurable distance and strength

## Algorithm Fidelity

The core algorithms are faithful ports:

- **Velocity Verlet integration**: Identical update equations
- **Alpha cooling**: Same exponential decay formula (`alpha += (alphaTarget - alpha) * alphaDecay`)
- **Barnes-Hut approximation**: Same theta threshold for multipole approximation
- **LCG constants**: Same multiplier (1664525), increment (1013904223), modulus (2^32)
- **Phyllotaxis initialization**: Same golden-angle spiral placement
- **Collision detection**: Same quadtree-accelerated pair detection

### Known Behavioral Differences

- Floating-point results may differ slightly due to JavaScript vs WASM double precision ordering
- Node iteration order matches d3 (array index order)
- The simulation does not use `requestAnimationFrame`; users call `tick()` or `run()` explicitly

## License Compliance

- moonforce is licensed under Apache-2.0
- The original d3-force ISC copyright notice is preserved in the LICENSE file
- Each source file includes attribution: "Ported from d3-force (ISC license, Mike Bostock)"
- The ISC license permits modification and redistribution with copyright notice retention
