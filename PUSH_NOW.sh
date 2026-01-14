#!/bin/bash

# CareLink Blood Pressure - Push to GitHub Script
# 使用这个脚本推送代码到 GitHub

echo "🚀 准备推送到 GitHub..."
echo ""

cd "/Users/kellypeng/Desktop/iHealth Andorid Native SDK V2.15.1 "

echo "📊 检查文件状态..."
git status
echo ""

echo "🔐 现在需要你的 GitHub 认证"
echo ""
echo "方法1: 使用 Personal Access Token (推荐)"
echo "  1. 访问: https://github.com/settings/tokens"
echo "  2. 点击 'Generate new token (classic)'"
echo "  3. 勾选 'repo' 权限"
echo "  4. 复制 Token (ghp_xxxxx)"
echo ""
echo "方法2: 使用 SSH"
echo "  参考 GITHUB_PUSH_GUIDE.md"
echo ""
echo "按回车继续推送..."
read

echo "🚀 开始推送..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 推送成功！"
    echo ""
    echo "🎉 访问你的仓库查看:"
    echo "   https://github.com/kalipeng/Carelink-Blood-pressure"
    echo ""
else
    echo ""
    echo "❌ 推送失败"
    echo ""
    echo "💡 常见解决方法:"
    echo "   1. 确保输入了正确的 Token (不是密码)"
    echo "   2. Token 需要有 'repo' 权限"
    echo "   3. 用户名是: kalipeng"
    echo ""
    echo "📖 详细指南: 查看 GITHUB_PUSH_GUIDE.md"
fi
