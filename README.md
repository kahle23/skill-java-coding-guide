# Skills Developer — 开发者技能集

一套面向 AI 编程助手的**开发者技能合集**。把表设计、功能设计、代码规范、工具库用法、项目协作工具等工程经验沉淀为结构化文档，让 AI 在协助开发时输出风格统一、质量稳定、贴合团队约定的代码与方案。

> 每个技能都是一个独立的目录，包含 `SKILL.md`（技能元数据与加载规则）和 `references/`（分主题的参考文档）。AI 按需查阅，不会一次性读取全部内容。

---

## 为什么需要这些技能

AI 写代码常见的问题：命名风格漂移、重复造轮子、忽略已有工具方法、异常处理与日志风格不一致、API 设计随意。这套技能通过把团队约定固化成文档，让 AI：

- **先复用再新建** — 编码前先搜索项目已有代码，避免重复造轮子
- **风格统一** — 命名、结构、注释、异常、日志遵循一致约定
- **善用工具库** — 优先使用 Hutool、Guava、Apache Commons 等成熟组件
- **规范输出** — API 遵循 RESTful、统一返回值、分页与错误码体系
- **设计先行** — 表结构、功能方案在动手前就有章可循

---

## 技能清单

| 技能 | 说明 | 状态 |
|------|------|------|
| [java-coding-standard](./java-coding-standard) | Java 编码规范与工具库（不绑定特定框架） | ✅ 已完成 |
| [python-coding-standard](./python-coding-standard) | Python 编码规范与最佳实践（不绑定特定框架） | ✅ 已完成 |
| [db-design-standard](./db-design-standard) | 数据库表结构设计规范（命名、标准字段、索引、SQL模板、禁止项） | ✅ 已完成 |
| [feature-design-workflow](./feature-design-workflow) | 功能设计文档工作流（需求概述→功能梳理→表结构→接口设计→业务逻辑，含阶段门禁） | ✅ 已完成 |
| [zentao-cli](./zentao-cli) | 禅道 CLI 使用指南（查询/操作禅道数据：产品、项目、执行、需求、Bug、任务等） | ✅ 已完成 |
| [git-convention](./git-convention) | Git 操作规范与约定（commit message 格式、提交流程、分支操作） | ✅ 已完成 |
| [code-to-doc-workflow](./code-to-doc-workflow) | 代码转文档工作流（从前后端代码逆向生成技术文档 + 用户使用文档） | ✅ 已完成 |
| [code-to-test-workflow](./code-to-test-workflow) | 代码转测试工作流（从前后端代码生成测试用例 + Playwright E2E 自动化脚本） | ✅ 已完成 |
| [requirement-doc-workflow](./requirement-doc-workflow) | 需求文档工作流（把模糊需求引导成可实现、边界清晰的需求文档，含可行性校验） | ✅ 已完成 |

> 技能之间相互独立，可按需选用；也鼓励把它们组合使用，覆盖从需求到设计到编码到测试的完整链路。

---

## 目录结构

```
skills-developer/
│
├── README.md              # 本文件
├── java-coding-standard/     # Java 编码指南
├── python-coding-standard/   # Python 编码指南
├── db-design-standard/       # 数据库表设计规范
├── feature-design-workflow/  # 功能设计文档工作流（含阶段门禁）
├── zentao-cli/            # 禅道 CLI 使用指南
├── git-convention/       # Git 操作规范与约定
├── code-to-doc-workflow/  # 代码转文档工作流（技术文档 + 用户文档）
├── code-to-test-workflow/ # 代码转测试工作流（测试用例 + Playwright 脚本）
└── requirement-doc-workflow/ # 需求文档工作流（需求澄清 + 可行性引导 + PRD 生成）
```

每个技能目录内部结构一致：`SKILL.md`（元数据与加载规则）+ `references/`（分主题参考文档，按编号区间组织）。具体文档清单见各技能的 `SKILL.md` 文档索引。

文档编号区间约定（各技能通用）：

- **01~02**：工作流与模板（AI 编码前必读）
- **03~08**：核心规范（通用知识）
- **21~40**：第三方框架/工具库
- **41~60**：公司内部包/框架（按需创建）
- **99**：其他（兜底收录，含完整示例）

---

## 如何使用

### 1. 安装技能

将技能目录（如 `java-coding-standard/`）放入你的项目中，AI 会自动识别 `SKILL.md` 并按场景查阅对应文档。

### 2. 典型场景

| 你对 AI 说的话 | AI 会参考的文档 |
|---------------|----------------|
| "帮我写一个用户服务类" | 01 → 03 → 07 → 22 |
| "设计一个导出数据的接口" | 01 → 08 → 05 |
| "优化这段代码的性能" | 06 → 04 |
| "用 Hutool 处理日期" | 22 |
| "帮我写并发任务处理" | 07 → 06 |
| "帮我设计一张业务表" | db: 01 → 03 → 02 |
| "写个 Python 脚本处理 CSV" | python: 01 → 04 → 06 |
| "这个功能怎么设计文档" | feature-workflow: 01 → 02 |
| "帮我写个规范的 commit" | git: 01 |
| "帮我梳理这个功能的文档" | code-to-doc-workflow: 01 → 02/03 |
| "这段代码怎么用，写个用户说明" | code-to-doc-workflow: 01 → 03 |
| "帮我给这个功能写测试" | code-to-test-workflow: 01 → 02 → 03 → 05 |
| "基于代码生成自动化测试脚本" | code-to-test-workflow: 01 → 03 → 05 |
| "帮我整理这个需求 / 写需求文档" | requirement-doc-workflow: 01 → 03 → 04 |
| "这个需求能不能实现 / 评估一下" | requirement-doc-workflow: 03 |
| "需求方就给了一句话，怎么办" | requirement-doc-workflow: 01（草台班子速查）→ 04 |

### 3. 定制技能

所有技能文档都是纯 Markdown，直接编辑即可调整风格偏好：

- **改命名风格** → 编辑 `03-code-standards.md`
- **停用某个工具库** → 删除或注释对应文档
- **加入公司内部包** → 按 `41-xxx.md` 命名新建文档
- **喂代码示例自学** → 发送代码片段，AI 按 `02` 模板提炼规则

详细定制方式见各技能目录下的 `README.md`（java-coding-standard、python-coding-standard）或 `SKILL.md`。

---

## 新增技能

每个技能是一个独立目录，建议结构：

```
{skill-name}/
├── README.md        # 技能说明：能做什么、如何使用、如何定制
├── SKILL.md         # 元数据：name、description、加载规则、文档索引
└── references/      # 分主题参考文档（按编号区间组织）
```

`SKILL.md` 头部需包含 frontmatter：

```markdown
---
name: {skill-name}
description: 技能描述与触发词，用于 AI 判断何时加载
---
```

命名建议：技能目录与 `name` 一致，用小写英文加连字符，如 `db-design-standard`、`feature-design-workflow`。

---

## 路线图

- [x] **java-coding-standard** — Java 编码规范与工具库
- [x] **python-coding-standard** — Python 编码规范与最佳实践
- [x] **db-design-standard** — 数据库表结构设计规范
- [x] **feature-design-workflow** — 功能设计工作流（含阶段门禁）
- [x] **zentao-cli** — 禅道 CLI 使用指南
- [x] **git-convention** — Git 操作规范与约定
- [x] **code-to-doc-workflow** — 代码转文档工作流（技术文档 + 用户文档）
- [x] **code-to-test-workflow** — 代码转测试工作流（测试用例 + Playwright 脚本）
- [x] **requirement-doc-workflow** — 需求文档工作流（需求澄清 + 可行性引导）
- [ ] **code-review-guide** — 代码审查清单与规范

---

## 许可

内部使用，按需自定义。

---

## 技能安装脚本（install-skills）

把本目录（`skills-developer`）下所有含 `SKILL.md` 的子目录，通过 **Windows 目录联接（Junction，免管理员权限）** 安装到各 AI 工具的全局技能目录。

- 一份源码、多处复用：链接目录的读写直接作用到本仓库（源目录），不会复制文件。
- 跨工具通用：这些技能遵循 Agent Skills 开放标准，WorkBuddy / Trae / Claude Code / Codex 共用同一套 `SKILL.md` 格式。

### 文件

| 文件 | 作用 |
|------|------|
| `install-skills.windows.ps1` | 核心脚本（逻辑） |
| `install-skills.windows.bat` | 双击入口，内部自动加 `-ExecutionPolicy Bypass` 绕开执行策略 |

> 平台区分：文件名带 `windows` 标识。未来做 Linux 版时新增 `install-skills.linux.sh` 即可一一对应。

### 快速开始

**双击 `install-skills.windows.bat`**：默认安装到 WorkBuddy。

**命令行指定 agent**：
```bat
install-skills.windows.bat -Agent claude    :: 只装 Claude Code
install-skills.windows.bat -Agent all       :: 一次装到全部五个 agent
install-skills.windows.bat -Skill java-coding-standard  :: 只装一个技能
install-skills.windows.bat -Agent all -DryRun           :: 预览，不实际执行
```

**查看完整帮助**：
```bat
install-skills.windows.bat -Help
powershell -File install-skills.windows.ps1 -Help
```

### 参数

| 参数 | 说明 |
|------|------|
| `-Agent <name>` | 目标 agent，取值见下表，默认 `workbuddy` |
| `-Dest <path>`   | 自定义目标目录（指定后覆盖 `-Agent`） |
| `-Skill <name>`  | 只处理指定技能（目录名）；不指定则处理全部 |
| `-Uninstall`     | 删除指向本仓库的链接；只删链接，不动源目录 |
| `-DryRun`        | 预览模式：只打印将要做什么，不实际执行（卸载也支持） |
| `-Force`         | 重建已存在但指向旧路径的链接（换机器/挪仓库后修复用） |
| `-LogFile <path>`| 把每次操作记录追加到指定文件，方便事后排查 |
| `-Help`          | 显示完整帮助 |

### `-Agent` 取值与对应 Windows 目录

| 取值 | 目标目录 |
|------|----------|
| `workbuddy`（默认） | `%userprofile%\.workbuddy\skills` |
| `trae`              | `%userprofile%\.trae\skills` |
| `trae-cn`           | `%userprofile%\.trae-cn\skills` |
| `claude`            | `%userprofile%\.claude\skills` |
| `codex`             | `%userprofile%\.agents\skills` **和** `%userprofile%\.codex\skills`（双目录，见下注） |
| `all`               | 以上**全部五个** |

### 常用示例

```bat
:: 装到 WorkBuddy（默认）
install-skills.windows.bat

:: 装到 Claude Code
install-skills.windows.bat -Agent claude

:: 一次装到全部 agent
install-skills.windows.bat -Agent all

:: 只装某个技能（目录名）
install-skills.windows.bat -Skill java-coding-standard

:: 预览：只看会做什么，不实际执行（安装/卸载都支持）
install-skills.windows.bat -Agent all -DryRun

:: 挪过仓库后，重建指向旧路径的失效链接
install-skills.windows.bat -Agent all -Force

:: 记录操作日志到文件，方便事后排查
install-skills.windows.bat -Agent all -LogFile "%userprofile%\skills-install.log"

:: 自定义任意目标目录
powershell -File install-skills.windows.ps1 -Dest "<你的目标目录>"

:: 卸载（仅删除指向本仓库的链接）
install-skills.windows.bat -Agent trae-cn -Uninstall

:: 卸载前先预览会删哪些
install-skills.windows.bat -Agent trae-cn -Uninstall -DryRun
```

### 新增 / 维护技能

1. 把带 `SKILL.md` 的子目录丢进本目录。
2. 双击 `install-skills.windows.bat`（或带 `-Agent`）。
3. 脚本自动识别新目录并创建链接，已存在同名链接会自动跳过；链接指向旧路径的会被标记为 stale，加 `-Force` 重建。

### 注意事项

1. **删除链接：优先用脚本卸载，手动删不要用 `rmdir /S`**
   批量移除用 `install-skills.windows.bat -Agent <name> -Uninstall`（内部用 .NET `Directory.Delete(path, recursive:false)`，只删链接、不碰源目录，比 `rmdir` 更安全）。单个手动删除用 `rmdir "%userprofile%\.workbuddy\skills\<名称>"` 也可以，但**千万别加 `/S`**——会递归删除真实源文件。> 坑：PowerShell 的 `Remove-Item` 在某些版本会跟随 junction 递归删源文件，脚本已规避，切勿自行改用 `Remove-Item`。
2. **Trae 兼容性**
   Trae 要求技能 `SKILL.md` 头部含 `name:` / `description:` 的 frontmatter 才显示。若装过去后 Trae 内不显示，逐个核对 SKILL.md 头部格式。
3. **Claude Code 需重启**
   Claude Code 只 watch「会话启动时已存在」的顶级 skills 目录。首次装完后请**重启 Claude Code**（或新开会话）才会加载新建的 `.claude\skills` 目录。
4. **编码**
   脚本保持纯 ASCII（无中文注释），以规避 PowerShell 5.1 读取无 BOM 的 UTF-8 时把中文当乱码解���报语法错的坑。
5. **Codex 双目录**
   Codex 不同版本扫描的技能目录不一致：社区多引用 `~/.agents/skills`，也有资料指向 `~/.codex/skills`。脚本对 `-Agent codex` 会**同时安装到这两个目录**，确保任意版本都能发现技能。若你的 Codex 只认其一、担心另一处重复，可用 `install-skills.windows.ps1 -Dest "%userprofile%\.codex\skills" -Uninstall` 只移除多余那处的链接（同理可移除 `.agents` 处）。安装/卸载都只动链接、不碰源目录。
6. **换机器 / 挪过仓库后链接失效**
   Junction 记录的是绝对路径，源目录搬走后旧链接会指向不存在的路径。重装脚本会把这些标记为 `Stale links`，加 `-Force` 即可批量重建。建议配合 `-DryRun` 先看一遍再正式跑。
7. **执行摘要**
   脚本结束时打印统计（`Installed / Recreated / Skipped / Stale / Uninstalled / Failed`）。任一操作失败时退出码为 `2`，成功为 `0`，便于在 CI 或批处理中判断结果。
