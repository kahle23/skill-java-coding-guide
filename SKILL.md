---
name: "java-coding-guide"
description: "Java编码指南，包含编码规范、设计模式、性能优化、常用工具库(hutool/guava/apache-commons)使用示例及AI编码工作流。适用于Java 1.6+项目，帮助编写高质量、风格统一的Java代码。当用户要求编写、审查或优化Java代码时触发此技能。"
---

# Java 编码指南

本技能为 AI 提供 Java 编码的最佳实践和风格规范，适用于 **Java 1.6 及以上版本**的项目，不绑定特定框架或技术栈。

---

## 使用指南

在编写 Java 代码前，请根据场景查阅对应文档：

| 场景 | 文档 |
|------|------|
| **编码前必读**：先搜已有代码、再复用、最后写新的 | [10-ai-workflow.md](references/10-ai-workflow.md) |
| 命名、类结构、注释、异常、日志、空值处理 | [01-code-standards.md](references/01-code-standards.md) |
| List/Set/Map 操作、Stream API、泛型 | [02-collection-and-stream.md](references/02-collection-and-stream.md) |
| 建造者、策略、模板方法、观察者等模式 | [03-design-patterns.md](references/03-design-patterns.md) |
| 字符串拼接、集合容量、装箱、缓存 | [04-performance.md](references/04-performance.md) |
| @Data/@Builder/@Slf4j 等注解 | [05-lombok.md](references/05-lombok.md) |
| StrUtil/CollUtil/DateUtil/JSONUtil/BeanUtil | [06-hutool.md](references/06-hutool.md) |
| ImmutableList/Preconditions/Cache/Hashing | [07-guava.md](references/07-guava.md) |
| StringUtils/CollectionUtils/BeanUtils | [08-apache-commons.md](references/08-apache-commons.md) |
| 收到代码示例时，按模板提炼并写入技能 | [98-code-examples-template.md](references/98-code-examples-template.md) |
| 无法归入以上类别的规范 | [99-others.md](references/99-others.md) |

---

## 快速决策树

```
编码前必读 → 10-ai-workflow（先搜再读最后写）
│
├─ 写新类/方法 → 01-code-standards（命名、结构、注释）
├─ 处理集合数据 → 02-collection-and-stream
├─ 设计类/接口架构 → 03-design-patterns
├─ 优化运行效率 → 04-performance
├─ 减少样板代码 → 05-lombok
├─ 字符串/日期/JSON/Bean 操作 → 06-hutool
├─ 不可变集合/缓存/哈希 → 07-guava
├─ 字符串/集合通用工具 → 08-apache-commons
├─ 收到代码示例 → 98-code-examples-template（提炼规则并写入技能）
└─ 无法归类的内容 → 99-others（兜底收录）
```

---

## 核心原则

0. **先找，再读，最后写** — 编码前先搜索项目中是否已有类似功能，能复用就不重写。详见 [10-ai-workflow.md](references/10-ai-workflow.md)
1. **命名即注释** — 名字要自解释，减少不必要的注释
2. **方法短小** — 一个方法只做一件事，不超过 50 行
3. **善用工具库** — 不要重复造轮子，优先使用成熟的工具类
4. **防御式编程** — 参数校验前置，空值处理明确
5. **保持一致性** — 团队统一风格比"最佳"风格更重要

---

*本技能适用于 Java 1.6+ 项目，涵盖 Java SE 标准库及主流第三方工具库。*
