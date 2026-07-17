# 提流程与安全规范

## 标准 5 步提流程

### 步骤 1：查看状态（并行执行）

```bash
git status
git diff
git log --oneline -10
```

- `git status`：查看有哪些文件变更
- `git diff`：查看具体改了什么
- `git log --oneline -10`：查看最近 commit 风格和当前版本号

### 步骤 2：分析变更，拟定 commit message

根据 diff 内容判断变更类型：

- 新增功能/接口 → `[feat]`
- 修复问题/Bug → `[fix ]`
- 优化/重构 → `[opti]` 或 `[refa]`
- 配置/依赖/构建 → `[misc]`

从 `git log --oneline -10` 获取版本号；无版本号则省略。

### 步骤 3：暂存文件

```bash
git add <具体文件路径>
```

- **只暂存本次相关的文件**，不要 `git add -A` 或 `git add .`
- 不要暂存敏感文件（.env、credentials 等）
- 不要暂存无关文件（IDE 配置、临时文件等）

### 步骤 4：提交

有版本号时：

```bash
git commit -m "[type][version] 描述信息"
```

无版本号时：

```bash
git commit -m "[type] 描述信息"
```

### 步骤 5：确认结果

```bash
git status
git log --oneline -3
```

## 安全注意事项

1. **提交前**：必须先 `git diff` 查看变更内容，确认无敏感信息
2. **不要提交**：.env 文件、API 密钥、数据库密码、证书文件
3. **冲突处理**：不要强行覆盖，先 `git pull --rebase` 再处理
4. **确认再推**：commit 后不自动 push，等用户确认

## 快速参考

| 操作 | 命令 |
|------|------|
| 查看状态 | `git status` |
| 查看变更 | `git diff` |
| 查看历史 | `git log --oneline -N` |
| 暂存文件 | `git add <file1> <file2>` |
| 提交 | `git commit -m "[type][ver] msg"` |
| 推送 | `git push` |
| 拉取 | `git pull --rebase` |
| 撤销暂存 | `git restore --staged <file>` |
| 撤销修改 | `git restore <file>` |
