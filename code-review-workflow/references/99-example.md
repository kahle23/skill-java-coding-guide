# 99 — 完整示例：Java Service 方法审查

本示例展示一次完整的代码审查，从输入到报告。包含代码 BUG 和逻辑 BUG 两类问题，展示疑似问题标注、背景获取、分级报告的完整用法。

---

## 场景

用户："帮我 review 一下这个订单创建的代码，OrderService.java"

用户提供了文件路径，未指定审查重点。

---

## 阶段 1：收集输入

拿到代码路径，读代码。

**被审查代码**（示例，约 50 行）：

```java
@Service
public class OrderService {

    @Autowired
    private OrderMapper orderMapper;
    @Autowired
    private ProductMapper productMapper;
    @Autowired
    private InventoryMapper inventoryMapper;

    /**
     * 创建订单
     */
    public Order createOrder(Long productId, Integer quantity, Long userId) {
        // 查产品
        Product product = productMapper.selectById(productId);

        // 算价格
        Double totalAmount = product.getPrice() * quantity;

        // 扣库存
        Inventory inventory = inventoryMapper.selectByProductId(productId);
        inventory.setStock(inventory.getStock() - quantity);
        inventoryMapper.updateById(inventory);

        // 建订单
        Order order = new Order();
        order.setProductId(productId);
        order.setQuantity(quantity);
        order.setUserId(userId);
        order.setAmount(totalAmount);
        order.setStatus(1); // ��付款
        order.setCreateTime(new Date());
        orderMapper.insert(order);

        return order;
    }
}
```

### Gate 1 检查

- [x] 用户指定了代码（OrderService.java）
- [x] 知道语言（Java）
- 用户没指定重点 → 默认全面审（代码 BUG + 逻辑 BUG）

**过门，进入阶段 2。**

---

## 阶段 2：审查

### 步骤 2a：代码 BUG 审查（对着 02 清单过）

| 清单项 | 发现 |
|--------|------|
| C1 空指针 | ⚠️ `product` / `inventory` 未判空。productId 不存在 → NPE |
| C2 资源泄漏 | 无（无手动资源操作） |
| C3 并发 | ⚠️ 扣库存"查-改-写"非原子，并发下超卖 |
| C4 安全 | 无明显注入（用了 MyBatis 参数化） |
| C5 异常 | ⚠️ 整个方法无 try-catch，扣库存成功但建订单失败 → 库存扣了订单没建 |
| C7 性能 | 3 次独立查询（可接受，非循环内） |
| J6 注解 | ⚠️ `@Transactional` 缺失！扣库存和建订单不在事务内 |

### Java 专项

| 清单项 | 发现 |
|--------|------|
| J3 日期 | `new Date()` 可用，但 java.time 更佳（改进级） |

### 步骤 2b：逻辑 BUG 审查（先获取背景）

**步骤 1 扫文档**：查找项目 `doc/` `docs/` 目录。

假设找到 `docs/order-business-rules.md`，内容包含：
- 订单金额 = 产品单价 × 数量（折扣另算，此处不含折扣）
- 库存不足时不应创建订单
- 同一用户对同一产品不可重复下单（防重复）

**步骤 2 知识库技能**：假设本项目装了 `taihong-knowledge`，委托 AI agent 查询补充确认了上述规则。

**背景充足度：🟢 充足**（有文档 + 知识库确认）

对着逻辑 BUG 清单过：

| 清单项 | 发现 |
|--------|------|
| L1 边界 | ⚠️ 未校验 quantity > 0；未校验库存是否充足（stock - quantity < 0） |
| L2 状态 | status 直接写 1，无非法状态防护（当前简单，可接受） |
| L3 幂等 | ⚠️ 无防重复下单（业务规则要求"同一用户同一产品不可重复"） |
| L4 金额 | ⚠️⚠️ **用 Double 算钱！** 浮点精度问题，金额计算致命错误 |
| L5 权限 | userId 从入参来，未校验是否当前登录用户（越权风险） |

### Gate 2 检查

- [x] 代码 BUG 专项过了
- [x] Java 专项过了
- [x] 逻辑 BUG 专项过了（背景充足）
- [x] 好代码也记了（方法职责清晰、命名达意）

**过门，进入阶段 3。**

---

## 阶段 3：输出报告

```markdown
# 代码审查报告

## 审查概要

- **审查对象**：`OrderService.java` — `createOrder` 方法（约 30 行）
- **审查维度**：代码 BUG（全量）+ 逻辑 BUG
- **业务背景来源**：项目 `docs/order-business-rules.md` + `taihong-knowledge` 知识库确认
- **背景充足度**：🟢 充足
- **发现问题**：🔴 致命 2 ｜ 🟠 严重 4 ｜ 🟡 建议 1 ｜ 🟢 肯定 1
- **一句话结论**：金额计算和事务缺失是致命问题必须修；库存校验、重复下单防护、空值处理需补齐。整体结构清晰，补完校验后可用。

---

## 🔴 致命问题（2 项）

### 1. 金额用 Double 计算，浮点精度丢失

- 📍 **位置**：`OrderService.java:18` — `Double totalAmount = product.getPrice() * quantity;`
- 🏷️ **类型**：逻辑BUG（L4 金额计算）
- 📝 **描述**：订单金额用 `Double` 计算。浮点数无法精确表示十进制小数，`0.1 + 0.2 != 0.3`，金额计算会产生精度丢失，导致账目对不上。
- 🔍 **根因**：Double 是二进制浮点，10 元 × 3 件在浮点运算后可能变成 29.999999...，入库后金额错误。
- 💡 **建议**：金额计算应使用 `BigDecimal`，或数据库存储用整数（分）。`new BigDecimal(product.getPrice()).multiply(new BigDecimal(quantity))`。

### 2. 扣库存与建订单不在同一事务，部分失败导致数据不一致

- 📍 **位置**：`OrderService.java:14-29` — 整个方法
- 🏷️ **类型**：代码BUG（C5 异常处理 / J6 注解误用）
- 📝 **描述**：方法先扣库存（line 20），后建订单（line 22-29），但方法没有 `@Transactional`。如果建订单时抛异常（如 DB 主键冲突），库存已扣但订单没建，数据不一致。
- 🔍 **根因**：两个写操作不在同一事务边界内，无法一起回滚。
- 💡 **建议**：方法加 `@Transactional(rollbackFor = Exception.class)`，确保扣库存和建订单原子性。

---

## 🟠 严重问题（4 项）

### 3. 并发扣库存可能超卖

- 📍 **位置**：`OrderService.java:16-20`
- 🏷️ **类型**：代码BUG（C3 并发问题）
- 📝 **描述**：扣库存是"查出来-减数量-写回去"三步，非原子操作。两个请求同时查到 stock=5，各减 1，都写回 4，实际卖了 2 个但库存只减了 1。
- 🔍 **根因**：TOCTOU（检查-执行竞态），读写分离无锁。
- 💡 **建议**：用乐观锁（库存字段加 version，`UPDATE inventory SET stock=stock-?, version=version+1 WHERE product_id=? AND version=?`）或直接 `UPDATE ... SET stock=stock-? WHERE stock >= ?`（DB 层保证不超卖）。

### 4. 未校验库存是否充足

- 📍 **位置**：`OrderService.java:16-20`
- 🏷️ **类型**：逻辑BUG（L1 边界条件）
- 📝 **描述**：直接 `stock - quantity`，未校验 `stock >= quantity`。库存不足时 stock 变负数，订单照样创建。
- 🔍 **根因**：缺少业务前置校验。
- 📌 **背景来源**：`docs/order-business-rules.md` 明确"库存不足时不应创建订单"。
- 💡 **建议**：扣减前校验 `if (inventory.getStock() < quantity) throw new BusinessException("库存不足")`。

### 5. 未防重复下单

- 📍 **位置**：`OrderService.java`（方法整体）
- 🏷️ **类型**：逻辑BUG（L3 幂等性）
- 📝 **描述**：方法无幂等控制，同一用户快速双击或网络重试会创建重复订单。
- 🔍 **根因**：无唯一约束、无幂等 token。
- 📌 **背景来源**：`docs/order-business-rules.md` 明确"同一用户对同一产品不可重复下单"。
- 💡 **建议**：数据库层加唯一约束（user_id + product_id + 状态），或应用层用幂等 token / 分布式锁。

### 6. product / inventory 未判空，NPE 风险

- 📍 **位置**：`OrderService.java:12`（product）、`OrderService.java:16`（inventory）
- 🏷️ **类型**：代码BUG（C1 空指针）
- 📝 **描述**：`productMapper.selectById(productId)` 和 `inventoryMapper.selectByProductId(productId)` 返回 null 时（产品不存在/无库存记录），后续直接调方法会 NPE。
- 💡 **建议**：查询后判空，null 时抛业务异常（"产品不存在"/"库存记录缺失"）。

---

## 🟡 改进建议（1 项）

### 7. new Date() 建议用 java.time

- 📍 **位置**：`OrderService.java:27`
- 🏷️ **类型**：改进（J3 日期 API）
- 📝 **描述**：`new Date()` 可用但 java.util.Date 是老旧 API。Java 8+ 推荐 `LocalDateTime.now()`，不可变、线程安全、API 更清晰。
- 💡 **建议**：可以考虑迁移到 `java.time` API。非必须，项目统一即可。

---

## 🟢 值得肯定（1 项）

### 8. 方法职责清晰，命名达意

- 📍 **位置**：`OrderService.java` 整体
- 🏷️ **类型**：值得肯定
- 📝 **描述**：`createOrder` 方法只做创建订单一件事，步骤清晰（查产品→算价→扣库存→建订单）。变量命名 `productId`/`quantity`/`totalAmount`/`order` 都准确达意，读代码就能理解意图。这个结构保持得很好。

---

## 审查范围说明

- ✅ **已审查**：`OrderService.java` 的 `createOrder` 方法（第 10-31 行）
- ⏭️ **未审查**：该类其他方法、`OrderMapper`/`ProductMapper`/`InventoryMapper` 的 SQL 实现、被调用的其他 Service
- 📌 **逻辑审查基于**：`docs/order-business-rules.md` + `taihong-knowledge` 知识库。如业务规则与此不一致，相关结论需复核。

---

**审查完成。以上为发现的问题和建议，是否需要我针对某个问题展开说明，或聚焦某个方面深入审查？**
```

---

## 示例要点解析

| 要点 | 在示例中的体现 |
|------|---------------|
| 两类 BUG 都覆盖 | 代码 BUG（事务/并发/空指针）+ 逻辑 BUG（金额/库存/重复） |
| 分级准确 | Double 算钱和事务缺失是致命；超卖/缺校验是严重；Date API 是建议 |
| 背景来源标注 | 每个逻辑 BUG 都标了"背景来源：docs/... 或知识库" |
| 对事不对人 | 描述全是"代码做了 X"，没有"你写错了" |
| 给建议不替做 | "可以考虑…""建议…"，修改权在用户 |
| 有肯定部分 | 第 8 条表扬了命名和结构 |
| 报告头尾完整 | 概要（一句话结论）+ 范围说明（审了什么没审什么） |
| 收尾开放式 | 问用户是否要深入，不替用户做决定 |
