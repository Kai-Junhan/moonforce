# 项目说明：moonforce（d3-force 的 MoonBit 移植）

## 一句话简介

将 JavaScript 生态中最经典的力导向图布局引擎 d3-force 移植为纯 MoonBit 库，为 MoonBit 生态提供零依赖、可确定性复现的图布局能力，并附带浏览器可视化 demo。

## 原项目信息（申报必填）

| 项 | 内容 |
|---|---|
| 原项目名称 | d3-force |
| 原项目链接 | https://github.com/d3/d3-force |
| 原项目版本 | v3.0.0（2021-06，API 稳定） |
| 原项目许可证 | ISC（OSI 认可的宽松许可证，允许修改与再分发，需保留版权声明） |
| 原项目规模 | 核心源码约 1,000 行 JS（src/ 下 11 个文件），官方测试完备 |
| 影响力 | ~2k stars，D3.js 官方模块，网络图/层级图/气泡图的事实标准布局方案 |

## 生态重复性调研结论（2026-07-23）

- mooncakes.io 全量检索 `force` / `d3` / `layout` / `graph` / `physics` / `quadtree`：
  - 无任何力导向/图布局库（`force`、`d3` 零结果）
  - `mizchi/layout`、`mizchi/crater-layout` 为 CSS/flexbox 界面布局，方向不同
  - `*/graph*` 类库均为图数据结构/解析（petgraph、graphviz 解析等），不含布局算法
  - `SupremeHuaji/Quadtree` 为独立四叉树小库，不含力导向模拟
- GitHub 检索 `moonbit force layout`：0 个仓库
- **结论：选题与现有生态不重复，填补空白。**

## 移植范围

### 移植（核心交付）

| 模块 | 说明 | 对应 d3-force 源码 |
|---|---|---|
| LCG 随机源 | 确定性线性同余随机数（保证初始化可复现） | `lcg.js` |
| 四叉树 | Barnes-Hut 近似所需的空间索引 | d3-quadtree（依赖库） |
| 模拟核心 | velocity Verlet 积分、alpha 冷却、事件 | `simulation.js`, `jiggle.js`, `constant.js` |
| forceCenter | 向心力 | `center.js` |
| forceCollide | 碰撞检测力 | `collide.js` |
| forceLink | 边/连接力 | `link.js` |
| forceManyBody | 电荷力（Barnes-Hut 加速） | `manyBody.js` |
| forceX / forceY | 轴向定位力 | `x.js`, `y.js` |
| forceRadial | 径向力 | `radial.js` |
| 事件分发 | tick / end 事件（最小实现，替代 d3-dispatch） | d3-dispatch（依赖库，简化移植） |

完整 API 面对齐 d3-force v3：`simulation.nodes/force/alpha/alphaMin/alphaDecay/alphaTarget/velocityDecay/tick/restart/stop/find/randomSource/on` 及各力的参数配置。

### 不移植（明确排除，README 中说明）

- d3-timer（浏览器动画帧调度）——demo 直接用 `requestAnimationFrame`；核心库保持纯计算、无平台依赖
- d3-force 的 DOM/SVG 渲染部分——渲染不属于 d3-force 本身（属 d3-selection），demo 自绘 Canvas
- forceCollide 之外的物理引擎功能（刚体、约束求解等），不属于 d3-force 范围

### 适配与修改（申报必填，初版计划）

1. API 风格 MoonBit 化：JS 链式 getter/setter → MoonBit 结构体 + 方法，类型安全
2. 节点模型：JS 动态对象 → MoonBit `Node` 结构体（`x/y/vx/vy/fx/fy/index` + 用户数据泛型）
3. 随机源显式注入：默认 LCG 固定种子（与 d3 一致、测试可复现），可通过 `randomSource` 替换
4. 事件系统简化为 tick/end 两类回调

## 技术路线

1. **核心库（纯 MoonBit，零依赖）**：先 LCG → 四叉树 → 模拟核心 → 7 种力；每步对照 d3-force 源码与官方测试移植
2. **测试**：移植 d3-force 官方测试（test/*.js）+ 关键不变量测试（收敛性、确定性、quadtree 正确性）
3. **可视化 demo**：MoonBit 编译 JS 后端 + Canvas 2D 渲染；支持节点拖拽（fx/fy 固定）、多种示例图；部署 GitHub Pages
4. **工程化**：GitHub Actions CI（check/test/fmt/demo 构建）、README（中英文）、CHANGELOG、发布 mooncakes.io

## 项目结构（规划）

```
moonforce/
├── moon.mod.json          # 模块定义
├── LICENSE                # Apache-2.0/MIT + d3-force ISC 版权保留说明
├── README.md / README.zh.md
├── src/
│   ├── lcg.mbt            # 确定性随机源
│   ├── quadtree.mbt       # 四叉树
│   ├── simulation.mbt     # 模拟核心（velocity Verlet + alpha 冷却）
│   ├── force_center.mbt   # 以下 7 种力
│   ├── force_collide.mbt
│   ├── force_link.mbt
│   ├── force_many_body.mbt
│   ├── force_x.mbt / force_y.mbt / force_radial.mbt
│   └── *_test.mbt         # 各模块测试
├── examples/
│   └── basic/             # 最小可运行示例（CLI 输出布局结果）
├── demo/                  # 浏览器可视化 demo（JS 后端 + Canvas）
├── .github/workflows/ci.yml
└── CHANGELOG.md
```

## 工作量估算

- 核心库：1,500~2,500 行
- 测试：1,500~2,500 行
- 示例 + demo：500~1,000 行
- 合计：约 4,000~6,000 行有效 MoonBit 代码，落在比赛参考区间

## 申报书素材（一页 PDF 内容草稿）

- **项目现有基础**：已完成选题调研与移植方案设计；仓库已搭建，核心模拟循环已跑通（报名前完成）
- **计划开发内容**：完整移植 d3-force v3 的模拟核心与全部 7 种力模型，配套测试、文档、可视化 demo
- **预期目标**：发布 mooncakes.io，成为 MoonBit 生态首个力导向图布局库；API 对齐 d3-force；demo 在线可玩
- **技术路线**：见上文「技术路线」4 步
- **预计交付**：核心库 + ≥N 个测试 + 在线 demo + 中英文文档 + CI
- **移植说明**：原项目 d3-force（ISC），移植范围与适配见上文

## 风险与对策

| 风险 | 概率 | 对策 |
|---|---|---|
| MoonBit 语法/工具链不熟拖慢进度 | 中 | 先用最小 demo 验证工具链；核心算法本身与语言无关 |
| 浮点差异导致与 d3 结果不一致 | 中 | 不追求逐位一致；以不变量（收敛、无重叠、确定性）为测试标准 |
| JS 后端 Canvas API 绑定工作量 | 低 | demo 用最小 FFI 绑定；只做绘制不管交互框架 |
| 报名/初审反馈延迟 | 低 | 尽早（7 月底前）提交报名，预留修改重提时间 |

## 决策记录

| 日期 | 决策 | 说明 |
|---|---|---|
| 2026-07-23 | 项目名暂定 `moonforce` | 发布时以 mooncakes.io 可用名为准 |
| 2026-07-23 | 核心库零依赖、平台无关 | 保证可发布性与可测试性；平台相关代码只出现在 demo |
