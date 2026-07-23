# moonforce 项目申报书

## 基本信息

- **项目名称**：moonforce：d3-force 的 MoonBit 移植
- **参赛者**：Kai-Junhan
- **联系方式**：（请填写）
- **GitHub 仓库链接**：https://github.com/Kai-Junhan/moonforce.git
- **项目方向**：MoonBit 力导向图布局基础库 / 可视化基础设施
- **是否为移植项目**：是

## 项目简介

moonforce 将 d3-force v3.0.0 的力导向图布局引擎完整移植到 MoonBit 生态，为网络可视化、知识图谱、社交网络分析、流程编辑器和交互式数据探索工具提供高性能、确定性的力模拟计算引擎。项目面向需要在 MoonBit 中构建图布局、物理模拟或粒子系统的库作者、工具开发者和应用开发者，提供 Velocity Verlet 积分器、Barnes-Hut N-body 近似（四叉树加速）、多种可组合力模型以及完整的模拟生命周期管理。

## 核心功能范围

- 提供力模拟引擎（Simulation），支持 alpha 衰减、速度阻尼、tick/end 回调和确定性随机（LCG）；
- 提供 7 种可组合力模型：
  - **force_center**：质心居中力
  - **force_collide**：碰撞检测力（基于四叉树加速）
  - **force_many_body**：N-body 万有引力/斥力（Barnes-Hut 近似）
  - **force_link**：弹簧连接力
  - **force_x / force_y**：位置吸引力
  - **force_radial**：径向约束力
- 提供高性能四叉树（QuadTree），支持插入、最近邻查询、前序/后序遍历；
- 支持节点固定（pin）、动态添加/移除力、模拟重启和节点重置；
- 提供基础版和高级版（_advanced）双层 API，兼顾易用性和灵活性；
- 提供确定性 LCG 随机数生成器，保证相同输入产生完全一致的布局结果；
- 提供 60+ 个测试用例，覆盖所有力模型、四叉树、模拟收敛和边界情况；
- 提供 5 个完整示例程序（随机图、树布局、径向布局、网格布局、聚类）；
- 编译目标为 WASM-GC，可直接在浏览器中运行交互式可视化。

## 移植或参考说明

- **原项目名称**：d3-force
- **原项目链接**：https://github.com/d3/d3-force
- **原项目许可证**：ISC License
- **本项目许可证**：ISC License

与原项目相比，本项目会做以下适配和重新设计：

- 使用 MoonBit 原生包结构、结构体和闭包组织代码，而非 JavaScript 模块和原型链；
- 四叉树采用 struct-of-arrays 布局以适配 MoonBit 的可变数组语义，替代 JavaScript 的对象引用树；
- LCG 使用 MoonBit 32-bit Int 原生溢出语义，等价于 JavaScript 的 `| 0` 截断；
- 力模型通过 `ForceConfig { init, apply }` 闭包对实现多态，替代 JavaScript 的 `force.initialize()` 方法模式；
- 提供标记参数（labeled parameters）风格的 API，比 d3 的链式调用更符合 MoonBit 惯用法；
- 移除 DOM 绑定和 timer 调度，专注纯计算引擎，便于在 WASM、CLI、服务端等场景使用；
- 以确定性为核心设计目标，所有随机行为通过可替换的 LCG 控制，方便测试和复现。

## 技术亮点

1. **完整的力模拟引擎**：7 种力模型可任意组合，覆盖绝大多数图布局场景
2. **Barnes-Hut 加速**：O(N log N) 的 N-body 计算，支持大规模图
3. **确定性保证**：相同输入永远产生相同布局，便于快照测试和 CI
4. **WASM-GC 原生**：编译为 WebAssembly，无需 JS 胶水代码即可在浏览器运行
5. **零依赖**：仅依赖 moonbitlang/core，无第三方包

## 项目进度

| 阶段 | 内容 | 状态 |
|------|------|------|
| Phase 0 | 项目骨架、构建配置 | ✅ 完成 |
| Phase 1 | 核心移植：7 种力、模拟、四叉树、LCG | ✅ 完成 |
| Phase 2 | 测试完善、构建修复、示例程序 | ✅ 完成 |
| Phase 3 | 浏览器交互式 Demo（Canvas 渲染） | 🔄 进行中 |
| Phase 4 | 发布到 mooncakes.io | 📋 计划中 |
