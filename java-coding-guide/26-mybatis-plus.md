# 26 MyBatis-Plus

## 字段置空操作

MyBatis-Plus 的 `updateById` 方法默认不会更新 null 值字段。需要显式将字段设置为 null 时，必须使用 `Wrappers.lambdaUpdate()`。

### 错误示例

```java
// ❌ 这样写不会将字段更新为 null
AssetRecord updateEntity = new AssetRecord();
updateEntity.setId(id);
updateEntity.setHolderUserId(null);
updateEntity.setHolderOrgId(null);
assetRecordService.updateById(updateEntity);  // null 字段被忽略
```

### 正确示例

```java
// ✅ 使用 Wrappers.lambdaUpdate() 显式设置 null
assetRecordService.update(new AssetRecord(), Wrappers.lambdaUpdate(AssetRecord.class)
        .set(AssetRecord::getHolderUserId, null)
        .set(AssetRecord::getHolderOrgId, null)
        .eq(AssetRecord::getId, id));
```

### 混合场景

当部分字段需要置空、部分字段正常更新时，分开处理：

```java
if (needClearHolder) {
    // 置空字段用 Wrappers
    assetRecordService.update(new AssetRecord(), Wrappers.lambdaUpdate(AssetRecord.class)
            .set(AssetRecord::getHolderUserId, null)
            .set(AssetRecord::getHolderOrgId, null)
            .set(AssetRecord::getStatus, toStatus)
            .eq(AssetRecord::getId, id));
} else {
    // 正常更新用 updateById
    AssetRecord updateEntity = new AssetRecord();
    updateEntity.setId(id);
    updateEntity.setStatus(toStatus);
    updateEntity.setHolderUserId(userId);
    assetRecordService.updateById(updateEntity);
}
```

### 依赖

```java
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
```
