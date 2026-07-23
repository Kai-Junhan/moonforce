# moonforce

[d3-force](https://github.com/d3/d3-force) v3.0.0 的 MoonBit 移植 — 基于 Velocity Verlet 积分的力导向图布局引擎。

A MoonBit port of [d3-force](https://github.com/d3/d3-force) v3.0.0 — force-directed graph layout using velocity Verlet integration.

[![Build](https://github.com/Kai-Junhan/moonforce/actions/workflows/ci.yml/badge.svg)](https://github.com/Kai-Junhan/moonforce/actions)
[![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg)](LICENSE)

## 概述 / Overview

**moonforce** 将 D3.js 力模拟引擎引入 MoonBit 生态。通过在图节点上模拟物理力，计算出美观、可读的网络布局。零外部依赖，确定性输出，编译为 WASM-GC。

**moonforce** brings the D3.js force simulation engine to the MoonBit ecosystem. It computes aesthetic, readable network layouts by simulating physical forces on graph nodes. Zero external dependencies, deterministic output, compiles to WASM-GC.

**应用场景 / Use cases:**
- 网络可视化（社交图谱、依赖树、知识图谱） / Network visualization (social graphs, dependency trees, knowledge graphs)
- 层次结构探索与树形布局 / Hierarchy exploration and tree layouts
- 气泡图与聚类布局 / Bubble charts and cluster layouts
- 带拖拽支持的交互式图编辑器 / Interactive graph editors with drag support
- 任何需要自动空间排布的图 / Any graph that needs automated spatial arrangement

## 特性 / Features

- 7 种可组合力类型：center、collide、link、manyBody、x、y、radial
- Barnes-Hut N-body 近似（四叉树加速，O(N log N)）
- 确定性输出（固定种子的 LCG 随机源）
- 可配置参数（strength、distance、theta、iterations）
- 节点固定（pin/unpin，支持拖拽交互）
- 最近邻搜索
- WASM-GC 目标 — 浏览器中无需 JS 胶水代码即可运行
- 除 `moonbitlang/core` 外零依赖

## 安装 / Installation

```bash
moon add Kai-Junhan/moonforce
```

## 快速开始 / Quick Start

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

## API 参考 / API Reference

### 节点 / Node

```moonbit
let n = @moonforce.Node::new_node()            // 自动放置（叶序螺旋）/ auto-placed via phyllotaxis
let n = @moonforce.Node::make(x=10.0, y=20.0)  // 指定位置 / specific position
let n = @moonforce.Node::fixed(x=5.0, y=5.0)   // 固定位置（不会移动）/ fixed (won't move)

n.fix(50.0, 60.0)   // 运行时固定节点 / pin node at runtime
n.unfix()            // 释放节点 / release node
```

### 模拟器 / Simulation

```moonbit
let sim = @moonforce.Simulation::new(nodes)

sim.add_force("center", @moonforce.force_center(x=0.0, y=0.0))
sim.add_force("charge", @moonforce.force_many_body())
sim.add_force("link", @moonforce.force_link([(0, 1), (1, 2)]))

sim.run()                          // 运行至收敛 / run to convergence
sim.tick(1)                        // 单次迭代 / single iteration
sim.restart()                      // 重置 alpha，重新运行 / reset alpha, re-run

let nearest = sim.find(x, y, radius)  // 最近节点 / nearest node
let alpha = sim.get_alpha()            // 当前 alpha 值 / current alpha
```

### 力模型 / Forces

| 力 / Force | 构造函数 / Constructor | 描述 / Description |
|-------|-------------|-------------|
| 居中力 Center | `force_center(x?, y?)` | 将质心拉向目标点 / Pulls centroid toward target point |
| 碰撞力 Collision | `force_collide(radius?)` | 防止节点重叠 / Prevents node overlap |
| 连接力 Link | `force_link(edges)` | 节点间弹簧连接 / Spring connections between nodes |
| 多体力 Many-Body | `force_many_body()` | N-body 电荷力（默认斥力）/ N-body charge (repulsion default) |
| X 定位力 | `force_x(x?)` | 推向目标 X 坐标 / Pushes toward target X coordinate |
| Y 定位力 | `force_y(y?)` | 推向目标 Y 坐标 / Pushes toward target Y coordinate |
| 径向力 Radial | `force_radial(radius?, x?, y?)` | 约束到圆形 / Constrains to circle |

每种力都有 `_advanced` 变体，支持完整参数控制：

Each force has an `_advanced` variant with full parameter control:

```moonbit
@moonforce.force_many_body_advanced(strength=-50.0, theta=0.5,
  distance_min=1.0, distance_max=500.0)
@moonforce.force_collide_advanced(radius=10.0, strength=0.8, iterations=3)
@moonforce.force_link_advanced(links)  // Link 结构体，支持逐边配置 / Link struct with per-link config
@moonforce.force_x_advanced(x=100.0, strength=0.3)
@moonforce.force_y_advanced(y=100.0, strength=0.3)
@moonforce.force_radial_advanced(radius=80.0, x=0.0, y=0.0, strength=0.5)
@moonforce.force_center_with_strength(x=0.0, y=0.0, strength=0.5)
```

### 连接 / Link

```moonbit
let link = @moonforce.Link::make(0, 1)               // 默认距离 30 / default distance 30
let link = @moonforce.Link::with_distance(0, 1, 50.0) // 自定义距离 / custom distance
```

## 示例程序 / Examples

包含 5 个完整示例程序：

Five complete example programs are included:

| 示例 / Example | 描述 / Description |
|---------|-------------|
| `examples/random_graph/` | 随机图（charge + center）/ Random graph with charge + center |
| `examples/tree_layout/` | 树形层次布局 / Tree hierarchy layout |
| `examples/radial_layout/` | 径向约束布局 / Radial constraint layout |
| `examples/grid_layout/` | 网格定位力布局 / Grid with positioning forces |
| `examples/cluster/` | 多聚类径向分离 / Multi-cluster with radial separation |

运行示例 / Run any example:

```bash
moon run examples/random_graph
```

## 浏览器演示 / Browser Demo

`web/` 目录提供了带拖拽交互的浏览器演示：

An interactive browser demo with drag interaction is available in `web/`:

```bash
moon build --target wasm-gc
# 用任意 HTTP 服务器提供 web/ 目录 / Serve with any HTTP server
python -m http.server 8080
# 浏览器打开 / Open in browser: http://localhost:8080/web/index.html
```

## 运行测试 / Running Tests

```bash
moon test                    # 运行全部 60 个测试 / run all 60 tests
moon check                   # 类型检查 / type check
moon build --target wasm-gc  # 构建 WASM / build WASM
```

## 项目结构 / Project Structure

```
moonforce/
├── moonforce.mbt          # 核心类型 (Node, ForceConfig) / Core types
├── simulation.mbt         # 模拟引擎 (Verlet 积分器) / Simulation engine
├── quadtree.mbt           # Barnes-Hut 空间索引 / Spatial index
├── lcg.mbt                # 确定性 LCG 随机数 / Deterministic random
├── force_center.mbt       # 居中力 / Center force
├── force_collide.mbt      # 碰撞检测力 / Collision force
├── force_link.mbt         # 弹簧/连接力 / Spring/link force
├── force_many_body.mbt    # N-body 电荷力 / N-body charge force
├── force_x.mbt            # X 轴定位力 / X-positioning force
├── force_y.mbt            # Y 轴定位力 / Y-positioning force
├── force_radial.mbt       # 径向约束力 / Radial constraint force
├── moonforce_test.mbt     # 34 个黑盒测试 / 34 blackbox tests
├── moonforce_wbtest.mbt   # 26 个白盒测试 / 26 whitebox tests
├── cmd/main/              # CLI 演示 / CLI demo
├── web/                   # 浏览器交互演示 / Browser interactive demo
├── examples/              # 5 个示例程序 / 5 example programs
├── PORTING.md             # 移植文档 / Porting documentation
└── CHANGELOG.md           # 版本历史 / Version history
```

## 从 d3-force 移植 / Porting from d3-force

本项目忠实移植了 **d3-force v3.0.0**（ISC 许可证，Mike Bostock）。

This is a faithful port of **d3-force v3.0.0** (ISC license, Mike Bostock).

MoonBit 适配要点 / Key adaptations for MoonBit:
- 结构体数组（struct-of-arrays）四叉树（替代 JS 对象引用树）/ Struct-of-arrays quadtree (vs JS object tree)
- `ForceConfig { init, apply }` 闭包对（替代原型方法）/ Closures (vs prototype methods)
- 32 位整数 LCG（等价于 JS `| 0` 位截断）/ 32-bit integer LCG (vs JS `| 0` bitwise truncation)
- 标记参数（替代 d3 链式调用）/ Labeled parameters (vs d3 method chaining)
- 无 DOM/定时器依赖 — 纯计算引擎 / No DOM/timer dependency — pure computation engine

详见 [PORTING.md](PORTING.md)。 / See [PORTING.md](PORTING.md) for detailed mapping.

## 许可证 / License

ISC 许可证，详见 [LICENSE](LICENSE)。

ISC License. See [LICENSE](LICENSE).

原始 d3-force 算法版权归 Mike Bostock 所有（ISC）。

Original d3-force algorithm copyright Mike Bostock (ISC).

