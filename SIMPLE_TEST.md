# 🧪 测试指南

## 1. 打开项目

```bash
open carelink.xcodeproj
```

## 2. 运行

1. 选择 "黄佳璐的iPad"
2. 按 `⌘ + R` 
3. 按 `⌘ + Shift + Y` 看日志

## 3. 测试内容

- [ ] **连接**：打开血压计，App显示 Connected
- [ ] **App按钮**：点"Start" → 血压计充气 → 点"Stop" → 停止
- [ ] **设备按钮**：按血压计上的按钮 → App界面自动变化
- [ ] **测量**：完成测量 → 显示结果 → 自动上传（看Console）
- [ ] **手动上传**：结果页面点"Upload"按钮

## 4. 看日志（在Console搜索）

- `[iHealthService]` - 蓝牙和测量
- `START command` - Start信号
- `STOP command` - Stop信号
- `Device button` - 设备按钮
- `Uploading` - 上传

## 5. 常见问题

**连不上设备？** 重启血压计和App

**上传失败？** 服务器未配置，数据已存本地

---

就这些！🎉
