#!/bin/bash
# ==========================================
# Feishu Push Script (Template)
# 飞书推送脚本（模板）
# ==========================================

# 使用前请先配置以下变量
FEISHU_DOC_TOKEN=""      # 飞书文档 Token
FEISHU_APP_ID=""         # 飞书应用 ID
FEISHU_APP_SECRET=""     # 飞书应用 Secret

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载配置（如果有）
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
fi

# 检查配置
check_config() {
    if [ -z "$FEISHU_DOC_TOKEN" ]; then
        echo "❌ 请先配置 FEISHU_DOC_TOKEN"
        exit 1
    fi
    
    if [ -z "$FEISHU_APP_ID" ] || [ -z "$FEISHU_APP_SECRET" ]; then
        echo "❌ 请先配置飞书应用 (FEISHU_APP_ID, FEISHU_APP_SECRET)"
        exit 1
    fi
}

# 获取飞书 Access Token
get_access_token() {
    local response=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d "{
            \"app_id\": \"$FEISHU_APP_ID\",
            \"app_secret\": \"$FEISHU_APP_SECRET\"
        }")
    
    echo "$response" | grep -oP '"tenant_access_token"\s*:\s*"\K[^"]+' | head -1
}

# 更新飞书文档
update_feishu_doc() {
    local token="$1"
    local html_content="$2"
    
    # 将 HTML 转换为飞书文档块
    # 这里需要实现具体的转换逻辑
    # 参考: https://open.feishu.cn/document/server/docs/docs/server-side-api/document/blocks/insert-blocks
    
    curl -s -X PUT "https://open.feishu.cn/open-apis/docx/v1/documents/$FEISHU_DOC_TOKEN" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d '{
            "document": {
                "title": "每日早报"
            }
        }'
    
    echo "📱 飞书文档更新完成（模板）"
}

# 主函数
main() {
    check_config
    
    echo "🚀 开始推送到飞书..."
    
    # 获取 Access Token
    local token=$(get_access_token)
    
    if [ -z "$token" ]; then
        echo "❌ 获取 Access Token 失败"
        exit 1
    fi
    
    echo "✅ 获取 Access Token 成功"
    
    # 读取 HTML 内容
    local html_content=$(cat "$SCRIPT_DIR/../daily-news.html")
    
    # 更新文档
    update_feishu_doc "$token" "$html_content"
}

main "$@"
