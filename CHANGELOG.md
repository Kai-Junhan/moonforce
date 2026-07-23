# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Interactive browser demo (`web/`) with Canvas rendering and drag interaction
- 5 complete example programs (random_graph, tree_layout, radial_layout, grid_layout, cluster)
- Project proposal document (PROJECT_PROPOSAL.md)
- Comprehensive README.md with API reference and usage examples

### Fixed
- `add_force` now calls force init automatically (matches d3-force behavior)
- LCG uses 32-bit integer arithmetic matching d3-force v3 `| 0` semantics
- Deprecated `assert_true!`/`assert_false!`/`assert_eq!` replaced with current syntax
- Read-only field access in blackbox tests (use `Node::make`/`Node::fixed` API)
- Quadtree test assertion (count includes internal nodes)

### Changed
- License changed from Apache-2.0 to ISC (matching upstream d3-force)
- Test suite expanded to 60 tests (34 blackbox + 26 whitebox)

## [0.1.0] - 2026-07-23

### Added
- Initial release: core force-directed graph layout engine
- Velocity Verlet simulation with alpha cooling
- 7 force types: center, collide, link, manyBody, x, y, radial
- Quadtree spatial indexing with Barnes-Hut approximation
- Deterministic LCG random source
- Phyllotaxis node initialization
- `Node::make`, `Node::fixed`, `Node::fix()`, `Node::unfix()` API
- `Simulation::find()`, `Simulation::run()`, `Simulation::init_forces()`
- `_advanced` variants for all forces with full parameter control
- `Link` struct with per-link distance/strength configuration
- Event callbacks (on_tick, on_end)
- CLI demo in `cmd/main/`
- GitHub Actions CI (check, fmt, test, build)
- PORTING.md documenting porting scope and adaptations
