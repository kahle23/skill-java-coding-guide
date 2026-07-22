---
name: java-coding-guide
description: Java编码规范与工具库指南。触发：Java代码编写/审查/优化/重构/调试、编码规范、并发编程、API设计、设计模式、性能优化、Lombok/Hutool/Baibao/Kunlun/Guava/Apache Commons/MyBatis-Plus。
---

# Java Coding Guide

不绑定特定框架，各版本通用。本文档为 AI 编写 Java 代码的统一规范入口。

> **版本注意**：文档中 Stream / Optional / Lambda / CompletableFuture / `List.of` 等特性需 Java 8+（部分需 9+）。低版本项目使用对应文档时，用传统写法替代这些语法即可。

## 工作流入口

所有编码任务遵循「先搜再读最后写」，详见 01。收到用户代码示例时按 02 沉淀规范。

## 文档索引与触发钩子

| 编号 | 主题 | 关键条目（按需读取触发条件） |
|-----|------|------|
| 01 | 工作流：先搜再读最后写 | 编码前搜索已有实现｜复用策略判断｜新代码遵循已有风格 |
| 02 | 代码示例学习模板 | 收到用户代码示例时｜将示例沉淀为规范条目｜去重与冲突处理 |
| 03 | 命名/结构/注释/异常/日志/空值 | 类/方法/变量命名｜卫语句控制流｜⚠️异常不吞｜ERROR带异常对象｜返回空集合非null |
| 04 | 集合与 Stream | List/Map/Set 选型｜Stream 中间/终端操作｜⚠️ID去重用distinct｜并行流谨慎用 |
| 05 | 设计模式 | 建造者/策略/模板/观察者/责任链/工厂/单例/适配器 |
| 06 | 性能优化 | ⚠️循环内不建对象｜自动装箱｜List转Set加速查找｜批量DB操作替代循环单查｜先测量再优化 |
| 07 | 并发编程 | ⚠️禁止Executors建线程池｜线程池参数/拒绝策略｜synchronized vs ReentrantLock｜CompletableFuture｜ThreadLocal必须remove |
| 08 | API 设计 | RESTful URL｜统一响应体 R/PageResult｜错误码体系｜全局异常处理｜分页约定 |
| 21 | Lombok | @Data/@Slf4j/@Builder｜⚠️继承加callSuper｜@Value不可变对象 |
| 22 | Hutool | StrUtil判空｜CollUtil分组/集合运算｜DateUtil日期｜JSONUtil｜BeanUtil拷贝｜IdUtil生成ID |
| 23 | Baibao & Kunlun 框架 | BaseServiceImpl 6泛型｜QueryMode查询模式｜DeleteStatus｜FillCfg数据填充｜PageUtil分页｜变更日志｜Excel导入导出 |
| 24 | Guava | 不可变集合｜Cache本地缓存｜Preconditions校验｜Joiner/Splitter｜RateLimiter限流｜EventBus |
| 25 | Apache Commons | StringUtils判空/默认值｜FileUtils文件操作｜CollectionUtils集合运算｜工具选择对比表 |
| 26 | MyBatis-Plus | ⚠️updateById不更新null字段｜用lambdaUpdate显式置空｜混合更新场景 |
| 99 | 其他（兜底） | 零散知识收录 |

## 加载规则

简单任务（改名/抽取方法/CRUD/项目已有成熟模式）跳过文档。其余按场景触发：

| 用户意图 | 读取文档 |
|---------|---------|
| 编写/修改任意 Java 代码（先搜项目已有实现） | 01 |
| 用户发来代码示例，希望沉淀风格 | 02 |
| 涉及命名、类结构、注释、异常处理、日志、空值安全 | 03 |
| 集合选型、List/Map/Set 操作、Stream 使用 | 04 |
| 设计模式、接口抽象、消除 switch-case | 05 |
| 性能优化、字符串/集合/循环/DB 批量 | 06 |
| 线程池、锁、并发、异步任务、CompletableFuture | 07 |
| REST API 设计、返回值、分页、错误码、Controller | 08 |
| 实体类、DTO、Lombok 注解使用 | 21 |
| 用 Hutool 处理字符串/集合/日期/JSON/Bean | 22 |
| 用 Baibao/Kunlun 写 Service、分页、数据填充、Excel | 23 |
| 用 Guava 做缓存/不可变集合/限流/校验 | 24 |
| 用 Apache Commons 做字符串/文件/集合操作 | 25 |
| MyBatis-Plus 字段置空、updateById 不生效 | 26 |

不确定时先读 01 判断。
