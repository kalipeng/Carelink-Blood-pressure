# 🚀 GitHub Push Guide

## ✅ 已完成的步骤

```bash
✅ git init                    # 初始化仓库
✅ git add .                   # 添加所有文件
✅ git commit                  # 提交 (12 files, 3354 lines)
✅ git remote add origin       # 添加远程仓库
```

---

## 🔐 需要认证

GitHub 需要你的登录信息才能推送代码。

---

## 📝 推送步骤

### 方法1: 使用 Personal Access Token (推荐)

#### 步骤1: 创建 GitHub Token

1. 打开浏览器，访问: https://github.com/settings/tokens
2. 点击 **"Generate new token"** → **"Generate new token (classic)"**
3. 设置：
   ```
   Note: CareLink Blood Pressure
   Expiration: 90 days (或更长)
   
   勾选权限:
   ✅ repo (全选)
   ```
4. 点击底部 **"Generate token"**
5. **复制 Token** (ghp_xxxxxxxxxxxx) - 只显示一次！

#### 步骤2: 推送代码

**在终端执行：**

```bash
cd "/Users/kellypeng/Desktop/iHealth Andorid Native SDK V2.15.1 "

git push -u origin main
```

**会提示输入：**
```
Username: kalipeng
Password: [粘贴你的 Token，不是 GitHub 密码！]
```

**成功！** 🎉

---

### 方法2: 使用 SSH (更安全，一次性设置)

#### 步骤1: 检查是否有 SSH Key

```bash
ls -la ~/.ssh
```

**如果看到 `id_rsa.pub` 或 `id_ed25519.pub`：** ✅ 已有 SSH key，跳到步骤3

**如果没有：** 执行步骤2

#### 步骤2: 生成 SSH Key

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

一直按回车（使用默认设置）

#### 步骤3: 复制公钥

```bash
cat ~/.ssh/id_ed25519.pub
# 或
cat ~/.ssh/id_rsa.pub
```

复制输出的整个内容（ssh-ed25519 开头）

#### 步骤4: 添加到 GitHub

1. 访问: https://github.com/settings/keys
2. 点击 **"New SSH key"**
3. Title: `My Mac`
4. Key: 粘贴刚才复制的内容
5. 点击 **"Add SSH key"**

#### 步骤5: 改用 SSH URL

```bash
cd "/Users/kellypeng/Desktop/iHealth Andorid Native SDK V2.15.1 "

# 移除旧的远程仓库
git remote remove origin

# 添加 SSH 远程仓库
git remote add origin git@github.com:kalipeng/Carelink-Blood-pressure.git

# 推送
git push -u origin main
```

**成功！** 🎉

---

## 🎯 快速推送命令

### 如果你已经有 Token 或 SSH 配置好：

```bash
cd "/Users/kellypeng/Desktop/iHealth Andorid Native SDK V2.15.1 "
git push -u origin main
```

---

## ✅ 推送成功后

访问你的仓库查看：
https://github.com/kalipeng/Carelink-Blood-pressure

你会看到：
```
✅ README.md
✅ preview.html
✅ raspberry_pi/
✅ 所有文档
✅ 完整的项目
```

---

## 🔄 以后如何更新代码

```bash
cd "/Users/kellypeng/Desktop/iHealth Andorid Native SDK V2.15.1 "

# 1. 添加修改的文件
git add .

# 2. 提交
git commit -m "Update: 描述你的修改"

# 3. 推送
git push
```

---

## 📊 推送的内容

### 文件清单 (12 files, 3354 lines):

```
✅ .gitignore                     # Git 忽略文件
✅ README.md                      # 项目说明
✅ START_HERE.md                  # 快速开始
✅ DEPLOYMENT_CHECKLIST.md        # 部署清单
✅ BLUETOOTH_PROTOCOL.md          # 蓝牙协议说明
✅ COMPATIBLE_DEVICES.md          # 兼容设备
✅ SCREEN_COMPARISON.md           # 屏幕对比
✅ preview.html                   # 前端界面 (753 lines)
✅ raspberry_pi/
   ├── backend.py                # Python 后端 (237 lines)
   ├── install.sh                # 安装脚本 (114 lines)
   ├── requirements.txt          # 依赖清单
   └── README.md                 # 详细文档 (309 lines)
```

**总计：3354 行代码！** 🎉

---

## 🆘 遇到问题？

### 问题1: `fatal: could not read Username`
**解决：** 使用上面的方法1或方法2进行认证

### 问题2: `Permission denied (publickey)`
**解决：** SSH key 没配置好，使用方法1 (Token) 或重新配置 SSH

### 问题3: `rejected - non-fast-forward`
**解决：**
```bash
git pull origin main --rebase
git push origin main
```

### 问题4: `Repository not found`
**解决：** 检查仓库名称是否正确：
- 正确: `kalipeng/Carelink-Blood-pressure`
- URL: https://github.com/kalipeng/Carelink-Blood-pressure

---

## 💡 推荐设置

### 设置 Git 用户信息（可选但建议）

```bash
git config --global user.name "Kelly Peng"
git config --global user.email "your_email@example.com"
```

这样提交记录会显示你的名字。

---

## 🎯 下一步

推送成功后：

1. **查看仓库**
   - 访问: https://github.com/kalipeng/Carelink-Blood-pressure
   - 确认所有文件都在

2. **添加描述**
   - 在 GitHub 仓库页面添加描述
   - 例如：`Senior-friendly blood pressure monitoring system for Raspberry Pi`

3. **添加 Topics**
   - 点击设置图标
   - 添加标签：`raspberry-pi`, `healthcare`, `bluetooth`, `blood-pressure`

4. **分享链接**
   - 把仓库链接分享给需要的人
   - 别人可以克隆使用：
     ```bash
     git clone https://github.com/kalipeng/Carelink-Blood-pressure.git
     ```

---

## 📱 从树莓派克隆项目

在树莓派上使用：

```bash
cd ~
git clone https://github.com/kalipeng/Carelink-Blood-pressure.git healthpad
cd healthpad/raspberry_pi
chmod +x install.sh
./install.sh
```

---

**准备好推送了吗？选择方法1或方法2，然后执行命令！** 🚀
