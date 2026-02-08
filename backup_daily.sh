#!/bin/bash
# Daily AI Digest - Generate daily HTML and archive old files
# 每天生成当日文件，归档历史文件

WORKSPACE_DIR="/Users/yangshibo/.openclaw/workspace"
TODAY=$(date +%Y-%m-%d)
MONTH=$(date +%Y-%m)

# 创建归档目录
mkdir -p "$WORKSPACE_DIR/morning/old/$MONTH"
mkdir -p "$WORKSPACE_DIR/afternoon/old/$MONTH"

# 1. 归档昨天的文件
for section in morning afternoon; do
  # 查找昨天或更早的文件（排除 template.html 和当日文件）
  old_file=$(ls -t "$WORKSPACE_DIR/$section/"*.html 2>/dev/null | grep -v "template.html" | grep -v "$TODAY" | head -1)
  
  if [ -n "$old_file" ]; then
    filename=$(basename "$old_file")
    mv "$old_file" "$WORKSPACE_DIR/$section/old/$MONTH/$filename"
    echo "✅ 归档: $section/old/$MONTH/$filename"
  fi
done

# 2. 从模板生成当日文件
cp "$WORKSPACE_DIR/morning/template.html" "$WORKSPACE_DIR/morning/${TODAY}.html"
cp "$WORKSPACE_DIR/afternoon/template.html" "$WORKSPACE_DIR/afternoon/${TODAY}.html"

echo "📅 生成当日文件:"
echo "   📰 morning/${TODAY}.html"
echo "   🌤️ afternoon/${TODAY}.html"

# 3. 清理 30 天前的旧归档
find "$WORKSPACE_DIR/morning/old" -name "*.html" -mtime +30 -delete
find "$WORKSPACE_DIR/afternoon/old" -name "*.html" -mtime +30 -delete
echo "🧹 已清理 30 天前的旧归档"
