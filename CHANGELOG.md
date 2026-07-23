# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `Node::make(~x, ~y)` factory for creating nodes at specific positions
- `Node::fixed(~x, ~y)` factory for creating fixed-position nodes
- `Node::fix()` and `Node::unfix()` methods for runtime position fixing
- `Simulation::find(x, y, radius)` to locate nearest node
- `Simulation::run()` for one-call convergence
- `Simulation::init_forces()` to explicitly initialize all registered forces
- `Simulation::get_alpha()`, `set_alpha()`, `set_alpha_min()`, `set_alpha_target()` accessors
- `Simulation::get_nodes()` accessor
- `force_x_advanced`, `force_y_advanced` with configurable strength
- `force_center_with_strength` with configurable strength parameter
- `force_collide_advanced` with configurable strength and iterations
- `force_many_body_advanced` with configurable strength, theta, distance_min, distance_max
- `force_radial_advanced` with configurable strength
- `force_link_advanced` accepting `Link` struct array with per-link distance and strength
- `Link` struct with `Link::make()` and `Link::with_distance()` constructors
- PORTING.md documenting porting scope, adaptations, and excluded features
- CHANGELOG.md
- Comprehensive test suite (40+ tests covering all forces and edge cases)
- Runnable demo in `cmd/main` demonstrating full simulation workflow

## [0.1.0] - 2026-07-23

### Added
- Initial release: core force-directed graph layout engine
- Velocity Verlet simulation with alpha cooling
- 7 force types: center, collide, link, manyBody, x, y, radial
- Quadtree spatial indexing with Barnes-Hut approximation
- Deterministic LCG random source
- Phyllotaxis node initialization
- Event callbacks (on_tick, on_end)
- GitHub Actions CI (check, fmt, test)
