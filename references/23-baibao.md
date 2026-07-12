# Baibao & Kunlun 框架使用指南

## 目录

1. [引入依赖](#一引入依赖)
2. [Baibao 框架](#二baibao-框架)
3. [Kunlun 框架](#三kunlun-框架)
4. [Service 层完整使用示例](#四service-层完整使用示例)
5. [典型调用链](#五典型调用链)

---

## 一、引入依赖

```xml
<dependency>
    <groupId>io.github.kahle23</groupId>
    <artifactId>baibao</artifactId>
    <version>最新版</version>
</dependency>
```

`baibao` 依赖中包含了 **kunlun** 框架，两者配合使用。

---

## 二、Baibao 框架

Baibao 提供 Service 基类、查询模式控制、删除状态等基础设施。

### 2.1 BaseServiceImpl — Service 基类

所有业务 Service 的实现类都继承 `BaseServiceImpl`，泛型定义如下：

```java
import baibao.db.jdbc.mybatisplus.base.BaseServiceImpl;

@Service
public class InvoiceServiceImpl extends BaseServiceImpl<InvoiceMapper, Invoice
        , InvoiceAddParam, InvoiceEditParam, InvoiceQuery, InvoiceResult> 
        implements InvoiceService {
}
```

**6 个泛型参数**：

| 位置 | 类型 | 说明 |
|------|------|------|
| 1 | `Mapper` | MyBatis-Plus Mapper 接口 |
| 2 | `Entity` | 数据库实体类 |
| 3 | `AddParam` | 新增参数对象 |
| 4 | `EditParam` | 编辑参数对象 |
| 5 | `Query` | 查询条件对象 |
| 6 | `Result` | 查询结果对象 |

### 2.2 QueryMode — 查询模式控制

`QueryMode` 控制 Service 方法的行为，决定是否需要执行 `processData` 和 `fillingData`：

```java
import baibao.common.enums.QueryMode;
import static baibao.common.enums.QueryMode.allowFill;
import static baibao.common.enums.QueryMode.allowProcess;
```

**可用模式**：

| 模式 | 说明 | 触发 processData | 触发 fillingData |
|------|------|:-:|:-:|
| `FULL` | 完整模式 | ✅ | ✅ |
| `ONLY_PROCESS` | 仅处理数据 | ✅ | ❌ |
| `ONLY_FILL` | 仅填充数据 | ❌ | ✅ |
| 无 / null | 不处理不填充 | ❌ | ❌ |

**使用示例**：

```java
// 方式一：通过静态判断方法
if (allowProcess(query)) { processData(query, result.getData()); }
if (allowFill(query))    { fillingData(query, result.getData()); }

// 方式二：手动判断
List<QueryMode> allow = Arrays.asList(QueryMode.FULL, QueryMode.ONLY_PROCESS);
if (nonNull(query) && nonNull(query.getQueryMode()) && !allow.contains(query.getQueryMode())) {
    return;  // 不满足条件，跳过处理
}
```

### 2.3 DeleteStatus — 删除状态枚举

```java
import baibao.common.enums.DeleteStatus;
```

软删除标记：

| 值 | 含义 |
|----|------|
| `0` | 未删除 |
| `1` | 已删除 |

```java
// 过滤未删除的记录
List<InvoiceUsage> activeUsageList = usageList.stream()
    .filter(u -> Objects.equals(u.getDeleteStatus(), 0))
    .collect(Collectors.toList());

// 标记为已删除
deleteEntity.setDeleteStatus(DeleteStatus.DELETED.getCode());
```

### 2.4 Actions — 内部常量

```java
import static baibao.common.constant.Actions.INTERNAL_BUS;
```

`INTERNAL_BUS` 是内部消息总线的标识，用于发送服务间消息。

---

## 三、Kunlun 框架

### 3.1 核心模块一览

| 模块 | 包路径 | 功能 |
|------|--------|------|
| 分页 | `kunlun.common` | `Page` 分页对象、常量 |
| 数据处理 | `kunlun.data` | Bean 转换、字典、数据填充 |
| 事件消息 | `kunlun.action` / `kunlun.message` | 事件驱动、消息总线 |
| 安全认证 | `kunlun.security` | 用户上下文 |
| 文件处理 | `kunlun.io.fileprocessor` | Excel 导入导出 |
| ID 生成 | `kunlun.generator.id` | 分布式 ID |
| 工具类 | `kunlun.util` | 分页辅助、集合操作 |

### 3.2 Bean 转换

```java
import kunlun.data.bean.BeanUtil;
```

```java
// Param -> Entity
Invoice entity = BeanUtil.beanToBean(param, Invoice.class);

// Entity -> Param
InvoiceEditParam param = BeanUtil.beanToBean(entity, InvoiceEditParam.class);

// List 批量转换
List<InvoiceResult> results = BeanUtil.beanToBeanInList(list, InvoiceResult.class);
```

### 3.3 数据填充（FillCfg）

```java
import kunlun.data.fill.classic.FillCfg;
import kunlun.data.fill.classic.DataCfg;
import kunlun.data.fill.classic.support.EnumSupplier;
import kunlun.data.fill.classic.support.MpServIdsSupplier;
```

#### 枚举值填充

将字段的编码值翻译为描述文本：

```java
FillCfg.of(result)
    .addDataConfig(DataCfg.of(EnumSupplier.of(InvoiceDirection.class))
        .addFieldConfig("invoiceDirection", "directionDesc", "description"))
    .fill();
```

字段映射规则：`addFieldConfig(sourceField, targetField, enumProperty)`

| 参数 | 说明 |
|------|------|
| `sourceField` | 源字段名（存放编码值的字段） |
| `targetField` | 目标字段名（存放翻译结果的字段） |
| `enumProperty` | 枚举类的属性名，如 `description`、`name` |

#### Service ID 填充

通过 Spring Service 自动查询关联数据并填充：

```java
FillCfg.of(data)
    .addDataConfig(DataCfg.of(MpServIdsSupplier.of(UserService.class, User::getId))
        .addFieldConfig("contractBizUserId", "contractBizUserTxt", "name"))
    .addDataConfig(DataCfg.of(MpServIdsSupplier.of(OrganizationService.class, Organization::getId))
        .addFieldConfig("contractOwningOrgId", "contractOwningOrgTxt", "abbr"))
    .fill();
```

字段映射规则：`addFieldConfig(idField, resultField, targetProperty)`

| 参数 | 说明 |
|------|------|
| `idField` | 存储 ID 的字段名 |
| `resultField` | Service 查询结果对象的字段名 |
| `targetProperty` | 从结果对象中提取的属性 |

### 3.4 字典管理

```java
import kunlun.data.dict.DataDict;
import kunlun.data.dict.DictUtil;
```

```java
// 获取单个字典组
List<DataDict> dicts = DictUtil.listByGroup("INVOICE_TYPE");

// 批量获取多个字典组，构建 name -> value 映射
Map<String, Map<String, String>> dictMaps = Stream.of(
        INVOICE_TYPE, INVOICE_RISK_LEVEL, INVOICE_SOURCE, INVOICE_STATUS, YES_NO
).collect(Collectors.toMap(
    Function.identity(),
    group -> DictUtil.listByGroup(group).stream()
        .collect(Collectors.toMap(DataDict::getName, DataDict::getValue))
));

// 使用字典映射进行值转换
if (invoiceTypeMap.containsKey(firstData.getInvoiceTypeTxt())) {
    invoice.setInvoiceType(Integer.parseInt(invoiceTypeMap.get(firstData.getInvoiceTypeTxt())));
}
```

`DataDict` 对象包含 `name`（显示名）和 `value`（编码值）两个字段。

### 3.5 分页工具

```java
import kunlun.util.PageUtil;
import kunlun.common.Page;
```

```java
// 开启分页
PageUtil.startPage(query.getPageNum(), query.getPageSize());

// 处理分页结果
Page<InvoiceResult> result = PageUtil.handleResult(list, InvoiceResult.class);

// 添加序号列
PageUtil.fillSerialNumber(result.getData(), result.getPageNum(), result.getPageSize());

// 构造空分页对象
Page<InvoiceResult> empty = Page.of();
```

### 3.6 分布式 ID 生成

```java
import kunlun.generator.id.IdUtil;
```

```java
// 按业务前缀生成唯一 ID
entity.setId(IdUtil.nextLong("invoice-id"));
```

### 3.7 安全与用户上下文

```java
import kunlun.security.SecurityUtil;
import kunlun.security.UserDetail;
```

```java
UserDetail userDetail = SecurityUtil.getUserDetail();
if (userDetail != null) {
    String userName = userDetail.getDisplayName();
}
```

### 3.8 事件与消息

```java
import kunlun.action.ActionUtil;
import kunlun.data.Event;
import kunlun.message.model.Message;
import kunlun.action.event.support.difference.FieldDifferenceBuilder;
import kunlun.util.function.difference.FieldCompareResult;
```

#### 发送内部消息

```java
ActionUtil.execute(INTERNAL_BUS, new Message(TOPIC, payload));
```

#### 记录变更日志

```java
ActionUtil.execute(Event.ofChangeLog()
    .setBusinessType(项目中的业务类型)
    .setBusinessId(bizId)
    .appendMessage(new FieldDifferenceBuilder(oldData, newData, targetClz) {
        @Override
        protected void preProcess(List<FieldCompareResult> results) {
            for (FieldCompareResult result : results) {
                if ("invoiceDirection".equals(result.getName())) {
                    FillCfg.of(result)
                        .addDataConfig(DataCfg.of(EnumSupplier.of(InvoiceDirection.class))
                            .addFieldConfig("oldValue", "oldValue", "description")
                            .addFieldConfig("newValue", "newValue", "description"))
                        .fill();
                }
            }
        }
    })
);
```

### 3.9 文件导入导出

```java
import kunlun.io.fileprocessor.ProcConfig;
import kunlun.io.fileprocessor.ProcResult;
import kunlun.io.fileprocessor.support.EasyExcelOneTimeImportProcessor;
import kunlun.io.fileprocessor.support.EasyExcelByteArrayBasedExportProcessor;
```

#### Excel 导入

```java
ProcResult result = new ProcConfig<MultipartFile, InvoiceImportResult>()
    .setFileProcessor(new EasyExcelOneTimeImportProcessor(
            InvoiceImportResult.class, "发票导入.xlsx"))
    .setStatusListener(状态更新器)
    .setOutputSaver(文件保存器)
    .setParam(file)
    .setDataConsumer((context, page) -> {
        Statistic statistic = context.getResult().getStatistic();
        List<InvoiceImportResult> dataList = page.getData();

        // 逐条处理数据...
        statistic.setSuccessCount(...);
        statistic.setFailureCount(...);
    })
    .execute();
```

#### Excel 导出

```java
ProcResult result = new ProcConfig<InvoiceQuery, InvoiceResult>()
    .setFileProcessor(new EasyExcelByteArrayBasedExportProcessor(
            InvoiceResult.class, "文件导出.xlsx"))
    .setParam(query)
    .setDataSupplier((context, pageId) -> {
        query.setPageNum((Integer) pageId);
        query.setPageSize(200);
        return queryPage(query);
    })
    .execute();
```

### 3.10 验证工具

```java
import static kunlun.data.validation.support.javax.ValidationUtil.validateToThrow;

// JSR-303/380 参数校验，校验失败抛异常
validateToThrow(query);
```

### 3.11 断言工具

```java
import static kunlun.exception.util.VerifyUtil.isFalse;
import static kunlun.exception.util.VerifyUtil.isTrue;

// 条件为 false 时抛异常
isFalse(condition, "错误提示消息");

// 条件为 true 时抛异常
isTrue(!condition, "错误提示消息");
```

### 3.12 常用常量

```java
import static kunlun.common.constant.Numbers.ONE;   // 1
import static kunlun.common.constant.Numbers.ZERO;  // 0
import static kunlun.common.constant.Symbols.MINUS;        // "-"
import static kunlun.common.constant.Symbols.UNDERLINE;    // "_"
```

---

## 四、Service 层完整使用示例

### 4.1 类声明与依赖注入

```java
@Slf4j
@Service
public class InvoiceServiceImpl extends BaseServiceImpl<InvoiceMapper, Invoice
        , InvoiceAddParam, InvoiceEditParam, InvoiceQuery, InvoiceResult> 
        implements InvoiceService {

    @Resource
    private InvoiceDetailService invoiceDetailService;
    @Resource
    private UserService userService;
    @Resource
    private CompanyService companyService;
    // ... 更多依赖
}
```

### 4.2 参数转换钩子

```java
@Override
protected Invoice fromAddParam(InvoiceAddParam param) {
    Invoice entity = BeanUtil.beanToBean(param, Invoice.class);
    entity.setId(IdUtil.nextLong("invoice-id"));
    entity.setPriceCurrency(SettleCurrency.CNY.getCode());
    entity.setBizStatus(InvoiceBizStatus.UNVERIFIED.getCode());
    return entity;
}

@Override
protected Invoice fromEditParam(InvoiceResult old, InvoiceEditParam param) {
    return BeanUtil.beanToBean(param, Invoice.class);
}
```

### 4.3 分页查询

```java
@Override
public Page<InvoiceResult> queryPage(InvoiceQuery query) {
    validateToThrow(query);

    if (query.isPaged()) {
        PageUtil.startPage(query.getPageNum(), query.getPageSize());
    }

    List<Invoice> list = list(buildQueryWrapper(query));
    if (CollUtil.isEmpty(list)) { return Page.of(); }

    Page<InvoiceResult> result = PageUtil.handleResult(list, InvoiceResult.class);

    if (query.isPaged()) {
        PageUtil.fillSerialNumber(result.getData(), result.getPageNum(), result.getPageSize());
    }

    // QueryMode 控制：按需执行处理和填充
    if (allowProcess(query)) { processData(query, result.getData()); }
    if (allowFill(query))    { fillingData(query, result.getData()); }

    return result;
}
```

### 4.4 查询条件构建

```java
@Override
protected MPJLambdaWrapper<Invoice> buildQueryWrapper(InvoiceQuery query) {
    return JoinWrappers.lambda(Invoice.class)
        .in(isNotEmpty(query.getIdList()), Invoice::getId, query.getIdList())
        .eq(nonNull(query.getInvoiceBizType()), Invoice::getInvoiceBizType, query.getInvoiceBizType())
        .like(isNotBlank(query.getSellerNameLike()), Invoice::getSellerName, query.getSellerNameLike())
        .ge(nonNull(query.getBeginIssueTime()), Invoice::getIssueTime, query.getBeginIssueTime())
        .le(nonNull(query.getEndIssueTime()), Invoice::getIssueTime, query.getEndIssueTime())
        .orderByDesc(Invoice::getIssueTime);
}
```

### 4.5 数据处理（processData）

```java
@Override
protected void processData(InvoiceQuery query, List<InvoiceResult> data) {
    // 提取 ID 列表，批量查询关联数据
    List<Long> idList = data.stream()
        .map(InvoiceResult::getId)
        .distinct()
        .collect(Collectors.toList());

    // 查询付款记录

    // 将关联数据填充到结果对象中...
}
```

### 4.6 数据填充（fillingData）

```java
@Override
protected void fillingData(InvoiceQuery query, List<InvoiceResult> data) {
    // 通过 MpServIdsSupplier 自动填充用户名称和组织简称
    FillCfg.of(data)
        .addDataConfig(DataCfg.of(MpServIdsSupplier.of(UserService.class, User::getId))
            .addFieldConfig("contractBizUserId", "contractBizUserTxt", "name"))
        .addDataConfig(DataCfg.of(MpServIdsSupplier.of(OrganizationService.class, Organization::getId))
            .addFieldConfig("contractOwningOrgId", "contractOwningOrgTxt", "abbr"))
        .fill();
}
```

### 4.7 变更日志（changeLog）

```java
@Override
protected void changeLog(Object bizId, Object oldData, Object newData, Class<?> targetClz, Object... arguments) {
    boolean ignoreNullNewValue = toBool(ArrayUtil.get(arguments, ONE), Boolean.FALSE);
    String methodLabel = toStr(ArrayUtil.get(arguments, ZERO), EMPTY);
    ActionUtil.execute(Event.ofChangeLog()
        .setBusinessType(业务类型的值)
        .setBusinessId(bizId)
        .appendMessage(new FieldDifferenceBuilder(oldData, newData, targetClz, ignoreNullNewValue) {
            @Override
            protected void preProcess(List<FieldCompareResult> results) {
                for (FieldCompareResult result : results) {
                    if ("invoiceDirection".equals(result.getName())) {
                        FillCfg.of(result)
                            .addDataConfig(DataCfg.of(EnumSupplier.of(InvoiceDirection.class))
                                .addFieldConfig("oldValue", "oldValue", "description")
                                .addFieldConfig("newValue", "newValue", "description"))
                            .fill();
                    }
                    // 其他字段类似处理...
                }
            }
        })
    );
}
```

### 4.8 Excel 导入

```java
@Override
@Transactional(rollbackFor = Exception.class)
public ProcResult importRecords(MultipartFile file, InvoiceImportParam param) throws IOException {
    preCheck(file, param);

    ProcResult result = new ProcConfig<MultipartFile, InvoiceImportResult>()
        .setFileProcessor(new EasyExcelOneTimeImportProcessor(
                InvoiceImportResult.class, "发票导入.xlsx"))
        .setStatusListener(状态更新器)
        .setOutputSaver(文件保存器)
        .setParam(file)
        .setDataConsumer((context, page) -> {
            Statistic statistic = context.getResult().getStatistic();
            List<InvoiceImportResult> dataList = page.getData();

            // 获取字典映射
            Map<String, Map<String, String>> dictMaps = Stream.of(
                    INVOICE_TYPE, INVOICE_RISK_LEVEL, INVOICE_SOURCE, INVOICE_STATUS, YES_NO
            ).collect(Collectors.toMap(
                Function.identity(),
                group -> DictUtil.listByGroup(group).stream()
                    .collect(Collectors.toMap(DataDict::getName, DataDict::getValue))
            ));

            // 逐条处理...
            for (InvoiceImportResult data : dataList) {
                try {
                    // 业务处理
                    statistic.setSuccessCount(statistic.getSuccessCount() + 1);
                } catch (Exception e) {
                    statistic.setFailureCount(statistic.getFailureCount() + 1);
                    data.setReason(e.getMessage());
                }
            }
        })
        .execute();

    return result;
}
```

### 4.9 Excel 导出

```java
@Override
public ProcResult exportRecords(InvoiceQuery query) {
    ProcResult result = new ProcConfig<InvoiceQuery, InvoiceResult>()
        .setFileProcessor(new EasyExcelByteArrayBasedExportProcessor(
                InvoiceResult.class, "文件导出.xlsx"))
        .setParam(query)
        .setDataSupplier((context, pageId) -> {
            query.setPageNum((Integer) pageId);
            query.setPageSize(200);
            return queryPage(query);
        })
        .execute();

    return result;
}
```

---

## 五、典型调用链

```
前端请求
  │
  ▼
Controller (Spring MVC)
  │
  ▼
Service.queryPage(query)
  ├── validateToThrow(query)              ← baibao/kunlun 参数校验
  ├── PageUtil.startPage(...)              ← kunlun 开启分页
  ├── list(buildQueryWrapper(query))       ← baibao BaseServiceImpl 基类方法
  ├── PageUtil.handleResult(...)           ← kunlun 结果转换
  ├── PageUtil.fillSerialNumber(...)       ← kunlun 添加序号
  │
  ├── allowProcess(query) → processData()  ← baibao QueryMode 控制
  │   └── 关联查询、业务计算
  │
  └── allowFill(query) → fillingData()     ← baibao QueryMode 控制
      └── FillCfg + MpServIdsSupplier 填充名称

  ▼
返回 Page<InvoiceResult>
```

---

## 六、Service 生命周期钩子总结

| 方法 | 调用时机 | 所属框架 | 用途 |
|------|---------|---------|------|
| `fromAddParam()` | 新增前 | kunlun | Param → Entity，设置默认值、ID |
| `fromEditParam()` | 编辑前 | kunlun | Param → Entity |
| `buildQueryWrapper()` | 查询前 | kunlun | 构建 MPJLambdaWrapper 查询条件 |
| `processData()` | 查询后 | baibao | 业务数据处理，受 QueryMode 控制 |
| `fillingData()` | 查询后 | baibao | 字段填充，受 QueryMode 控制 |
| `changeLog()` | 变更后 | kunlun | 记录数据变更日志 |
| `addRecord()` / `editRecord()` | CRUD | baibao | 基类提供，内部调用上述钩子 |
