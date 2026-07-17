# 03 — 表设计规范

## 1. 表名规范

- 采用 `小写下划线` 命名法
- 格式：`模块前缀_业务中段_表意后缀`，如 `oa_asset_record`
- 前缀需与现有项目模块保持一致
- 禁止使用复数形式
- 禁止使用 `_info` 等语义模糊的后缀（如 `oa_asset_info` → `oa_asset_record`）

## 2. 必含标准字段

所有业务表必须包含以下字段：

| 字段名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `id` | bigint(20) | AUTO_INCREMENT | 主键 |
| `platform` | varchar(50) | '' | 平台信息 |
| `tenant_id` | varchar(50) | '' | 租户ID |
| `owner_id` | bigint(20) | — | 数据所属人ID |
| `own_org_id` | bigint(20) | — | 数据所属机构ID |
| `create_user` | bigint(20) | — | 创建者 |
| `create_time` | datetime | — | 创建时间 |
| `modify_user` | bigint(20) | — | 修改者 |
| `modify_time` | datetime | CURRENT_TIMESTAMP | 修改时间 |
| `delete_status` | tinyint(4) | 0 | 删除状态：0 未删除，1 已删除 |

## 3. 字段命名规范

- 小写下划线命名，如 `purchase_date`、`holder_user_id`
- 外键字段格式：`[业务名]_[关联表主键名]`，如 `holder_user_id`
- 状态类字段用 `status`，类型 tinyint，配合字典表
- 日期类字段用 `date` 类型（如 `purchase_date`、`operate_date`）
- 时间戳类字段用 `datetime` 类型（如 `create_time`）

## 4. 索引规范

- 主键：`PRIMARY KEY (id) USING BTREE`
- 唯一索引：`uk_[字段名]`，如 `uk_asset_no`
- 普通索引：`idx_[字段名]`，如 `idx_status`、`idx_holder_user_id`
- 复合索引按需设计，命名体现关键字段

## 5. SQL 输出格式

```sql
-- ----------------------------
-- Table structure for [表名]
-- ----------------------------
DROP TABLE IF EXISTS `[表名]`;
CREATE TABLE `[表名]` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  -- 业务字段...
  `platform` varchar(50) NOT NULL DEFAULT '' COMMENT '平台信息',
  `tenant_id` varchar(50) NOT NULL DEFAULT '' COMMENT '租户ID',
  `owner_id` bigint(20) NOT NULL COMMENT '数据的所属人ID',
  `own_org_id` bigint(20) NOT NULL COMMENT '数据的所属机构ID',
  `create_user` bigint(20) NOT NULL COMMENT '创建者',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `modify_user` bigint(20) NOT NULL COMMENT '修改者',
  `modify_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `delete_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '删除状态：0 未删除，1 已删除',
  PRIMARY KEY (`id`) USING BTREE,
  -- 其他索引...
) ENGINE = InnoDB AUTO_INCREMENT = 1 COMMENT = '[表中文说明]' ROW_FORMAT = Dynamic;
```

## 6. 禁止项

- 不要显式指定 `CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci`（由数据库默认字符集控制）
- 不要遗漏任何标准字段
- 不要在表名中使用复数形式
- 不要使用 `_info` 等语义模糊的表名后缀，用具体含义的词替代（如 `_record`、`_config`）
- 不要在 CREATE TABLE 中使用 `FOREIGN KEY` 约束（数据库物理外键），关联关系通过逻辑外键表达（字段命名 + 索引）

## 7. 输出要求

每次输出表结构时，必须同时提供：
1. 完整的 CREATE TABLE SQL 语句
2. 索引设计说明（支撑哪些查询场景）
3. 字段填写说明（必填项、默认值、特殊业务含义）
4. 与现有表的关联关系（逻辑外键，非物理外键）
