# 分支操作规范

## 分支命名

| 类型 | 命名格式 | 示例 |
|------|----------|------|
| 功能分支 | `feature/<模块名>` | `feature/asset-import` |
| 修复分支 | `fix/<问题描述>` | `fix/qr-code-error` |
| 优化分支 | `opti/<优化内容>` | `opti/import-performance` |

## 推送代码

```bash
# 首次推送并设置上游分支
git push -u origin <branch-name>

# 后续推送
git push
```

## 禁止操作

以下操作除非用户明确要求，否则一律禁止：

- `git push --force` — 强制推送覆盖远程历史
- `git reset --hard` — 丢弃所有本地修改
- `git branch -D` — 强制删除分支
- 直接推送到 main/master — 主分支必须通过 PR/MR 合入
