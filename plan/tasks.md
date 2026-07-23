# 任务清单

图例：⬜ 待办　🔵 进行中　✅ 完成　⚠️ 受阻（注明原因）

> 更新规则：每日开发结束更新本文件；任务有增删改时同步检查 roadmap.md 是否受影响。

## Phase 0：环境与仓库

| 状态 | 任务 | 备注 |
|---|---|---|
| ✅ | 安装 MoonBit 工具链（含 VS Code 插件可选） | 已装：moon 0.1.20260703，位于 `~/.moon/bin`（2026-07-23 验证） |
| 🔵 | 验证 `moon new / build / test` 跑通 hello world | version 已验证，待跑完整流程 |
| 🔵 | 确定 GitHub 用户名与仓库名 | 仓库名定为 moonforce；等待用户提供用户名 |
| ⬜ | 创建公开仓库：LICENSE、README 占位、.gitignore | |
| ⬜ | 搭建 moon 模块骨架（src/examples/demo 目录） | |
| ⬜ | 配置 GitHub Actions 最小 CI（moon check + test） | |
| ⬜ | 注册 mooncakes.io 账号（`moon login`） | 绑定 GitHub |

## Phase 1：核心移植

| 状态 | 任务 | 备注 |
|---|---|---|
| ⬜ | 移植 LCG 确定性随机源 + 测试 | 对应 d3-force lcg.js |
| ⬜ | 移植四叉树（insert/remove/visit/find）+ 测试 | 对应 d3-quadtree |
| ⬜ | 移植模拟核心（velocity Verlet、alpha 冷却、tick） | 对应 simulation.js/jiggle.js |
| ⬜ | 移植 forceCenter + 测试 | |
| ⬜ | 移植 forceCollide + 测试 | 依赖四叉树 |
| ⬜ | 移植 forceLink + 测试 | |
| ⬜ | 移植 forceManyBody + 测试 | 依赖四叉树 Barnes-Hut |
| ⬜ | 移植 forceX / forceY + 测试 | |
| ⬜ | 移植 forceRadial + 测试 | |
| ⬜ | 事件机制（tick/end 回调） | 简化版 d3-dispatch |
| ⬜ | 整理公开 API（包导出、文档注释） | |

## Phase 2：报名

| 状态 | 任务 | 备注 |
|---|---|---|
| ⬜ | README 初版（用途/功能/用法/移植说明） | |
| ⬜ | 撰写一页申报书并导出 PDF | 素材见 project.md |
| ⬜ | 填写飞书报名问卷并提交 | 需用户本人信息，用户操作 |

## Phase 3：测试与 demo

| 状态 | 任务 | 备注 |
|---|---|---|
| ⬜ | 移植 d3-force 官方测试套件 | test/*.js 全量对照 |
| ⬜ | 不变量测试：确定性（同种子同结果）、收敛性、碰撞无重叠 | |
| ⬜ | demo：MoonBit → JS 构建跑通 | |
| ⬜ | demo：Canvas 渲染节点与边 | |
| ⬜ | demo：动画循环（tick 驱动）+ 节点拖拽（fx/fy） | |
| ⬜ | demo：多示例切换（随机图/树/网格） | |
| ⬜ | demo 部署 GitHub Pages | |

## Phase 4：发布与文档

| 状态 | 任务 | 备注 |
|---|---|---|
| ⬜ | `moon publish` 发布 v0.1.0 至 mooncakes.io | |
| ⬜ | README 完善（中英文、demo 截图、API 摘要） | |
| ⬜ | PORTING.md：移植范围/适配/未支持功能对照表 | 验收要求 |
| ⬜ | CHANGELOG.md 建立 | |
| ⬜ | CI 完善（fmt 检查、demo 构建、多后端 check） | |
| ⬜ | 代码行数统计与质量自查 | 目标 4,000+ 有效行 |

## Phase 5：验收准备

| 状态 | 任务 | 备注 |
|---|---|---|
| ⬜ | 整理验收材料（提交记录/测试记录/发布记录/设计说明） | |
| ⬜ | 按初审反馈修改（如有） | |
| ⬜ | 最终自查对照 requirements.md 验收清单逐项打勾 | |

## 当前进行中

（暂无，等待用户确认环境与 GitHub 账号后开始 Phase 0）
