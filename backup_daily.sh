#!/bin/bash
# Daily AI Digest Backup Script
# 每天自动备份 HTML 文件到历史目录，按月份归档

WORKSPACE_DIR="/Users/yangshibo/.openclaw/workspace"
DATE=$(date +%Y-%m-%d)
MONTH=$(date +%Y-%m)
TIME=$(date +%H-%M-%S)

# 创建月份归档目录
mkdir -p "$WORKSPACE_DIR/morning/old/$MONTH"
mkdir -p "$WORKSPACE_DIR/afternoon/old/$MONTH"

# 备份文件
cp "$WORKSPACE_DIR/morning/template.html" "$WORKSPACE_DIR/morning/old/$MONTH/${DATE}_${TIME}_morning.html"
cp "$WORKSPACE_DIR/afternoon/template.html" "$WORKSPACE_DIR/afternoon/old/$MONTH/${DATE}_${TIME}_afternoon.html"

echo "✅ 备份完成："
echo "   📰 morning/old/$MONTH/${DATE}_${TIME}_morning.html"
echo "   🌤️ afternoon/old/$MONTH/${DATE}_${TIME}_afternoon.html"

# 保留最近 30 天的备份
find "$WORKSPACE_DIR/morning/old" -name "*.html" -mtime +30 -delete
find "$WORKSPACE_DIR/afternoon/old" -name "*.html" -mtime +30 -delete
echo "🧹 已清理 30 天前的旧备份"
