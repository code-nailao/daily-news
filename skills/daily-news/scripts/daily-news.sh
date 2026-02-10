#!/bin/bash
# ==========================================
# Daily News Briefing - Main Script
# 每日早报生成主脚本
# ==========================================

# 确保在 skill 目录中运行
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# 加载配置（如果有）
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
fi

# ==========================================
# 默认配置
# ==========================================
DATE="${DATE:-$(date +%Y-%m-%d)}"
WEATHER_CITY="${WEATHER_CITY:-上海}"
PROXY="${PROXY:-http://127.0.0.1:7897}"
SKIP_GIT="${SKIP_GIT:-0}"
SKIP_FEISHU="${SKIP_FEISHU:-1}"
OUTPUT_DIR="${OUTPUT_DIR:-$SKILL_DIR}"
VERBOSE="${VERBOSE:-0}"

WEATHER_URL="wttr.in/$WEATHER_CITY"
HACKER_NEWS_URL="https://news.ycombinator.com/newest"
QBITAI_URL="https://www.qbitai.com"
DAILY_NEWS_FILE="$OUTPUT_DIR/daily-news.html"

# ==========================================
# 颜色输出
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { [ "$VERBOSE" = "1" ] && echo -e "${CYAN}[DEBUG]${NC} $1"; }

# ==========================================
# 1. 获取天气
# ==========================================
get_weather() {
    log_info "获取天气信息 ($WEATHER_CITY)..."
    WEATHER=$(curl -s --connect-timeout 5 "$WEATHER_URL?format=3" 2>/dev/null)
    
    if [ -z "$WEATHER" ]; then
        WEATHER="☁️ $WEATHER_CITY: 天气信息获取失败"
        log_warning "天气获取失败"
    else
        log_debug "天气: $WEATHER"
    fi
    echo "$WEATHER"
}

# ==========================================
# 2. 获取 Hacker News
# ==========================================
get_hacker_news() {
    log_info "获取 Hacker News..."
    
    # 尝试使用代理
    HN_CONTENT=$(curl -s --proxy "$PROXY" --connect-timeout 10 "$HACKER_NEWS_URL" 2>/dev/null)
    
    # 如果代理失败，尝试直接连接
    if [ -z "$HN_CONTENT" ]; then
        log_warning "代理连接失败，尝试直接访问..."
        HN_CONTENT=$(curl -s --connect-timeout 15 "$HACKER_NEWS_URL" 2>/dev/null)
    fi
    
    if [ -z "$HN_CONTENT" ]; then
        log_error "Hacker News 获取完全失败"
        echo "1. Hacker News 获取失败"
        return 1
    fi
    
    # 解析前 5 条新闻
    HN_ITEMS=$(echo "$HN_CONTENT" | grep -A2 'class="titleline"' | head -20 | \
        grep -E '>([^<]+)<' | sed 's/<[^>]*>//g' | head -5)
    
    if [ -z "$HN_ITEMS" ]; then
        echo "1. 暂无热门新闻"
    else
        # 清理并编号
        echo "$HN_ITEMS" | nl -w2 -s'. ' | sed 's/^[ ]*//'
    fi
}

# ==========================================
# 3. 获取量子位新闻
# ==========================================
get_qbitai_news() {
    log_info "获取量子位新闻..."
    
    # 国内网站，不需要代理
    QBITAI_CONTENT=$(curl -s --connect-timeout 10 "$QBITAI_URL" 2>/dev/null)
    
    if [ -z "$QBITAI_CONTENT" ]; then
        log_warning "量子位直接访问失败，尝试 web_fetch..."
        # 使用 web_fetch 作为备用
        QBITAI_CONTENT=$(web_fetch "$QBITAI_URL" 2>/dev/null || echo "")
    fi
    
    if [ -z "$QBITAI_CONTENT" ]; then
        log_error "量子位获取完全失败"
        echo "1. 量子位新闻获取失败"
        return 1
    fi
    
    # 解析新闻标题（多种方式尝试）
    QBITAI_ITEMS=$(echo "$QBITAI_CONTENT" | grep -oP '(?<=<h2 class="entry-title"><a href=")[^"]*' 2>/dev/null | head -5)
    
    if [ -z "$QBITAI_ITEMS" ]; then
        QBITAI_ITEMS=$(echo "$QBITAI_CONTENT" | grep -oP '(?<=<h2>)[^<]+' 2>/dev/null | head -5)
    fi
    
    if [ -z "$QBITAI_ITEMS" ]; then
        echo "1. 暂无国内科技新闻"
    else
        # 清理并编号
        echo "$QBITAI_ITEMS" | nl -w2 -s'. ' | sed 's/^[ ]*//'
    fi
}

# ==========================================
# 4. 生成 HTML 报告
# ==========================================
generate_html_report() {
    local weather="$1"
    local hn_news="$2"
    local qbitai_news="$3"
    
    log_info "生成 HTML 报告..."
    
    # 准备新闻列表
    HN_LIST=$(echo "$hn_news" | sed 's/^/                <li>/' | sed 's/$/<\/li>/')
    QBITAI_LIST=$(echo "$qbitai_news" | sed 's/^/                <li>/' | sed 's/$/<\/li>/')
    
    # HTML 模板
    cat > "$DAILY_NEWS_FILE" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>每日早报 - $DATE</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            font-size: 2em;
            margin-bottom: 10px;
        }
        .header .date {
            opacity: 0.9;
            font-size: 1.1em;
        }
        .content {
            padding: 30px;
        }
        .section {
            margin: 30px 0;
        }
        .section h2 {
            color: #667eea;
            font-size: 1.4em;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .weather {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 25px;
            border-radius: 12px;
            font-size: 1.1em;
            line-height: 1.6;
        }
        ul {
            list-style: none;
            padding: 0;
        }
        ul li {
            padding: 12px 15px;
            margin: 8px 0;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #667eea;
            line-height: 1.5;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        ul li:hover {
            transform: translateX(5px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .todo li {
            border-left-color: #28a745;
        }
        .footer {
            background: #f8f9fa;
            padding: 20px 30px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
        .footer .timestamp {
            color: #999;
            margin-bottom: 10px;
        }
        .footer .credit {
            opacity: 0.7;
        }
        @media (max-width: 600px) {
            body { padding: 10px; }
            .content { padding: 20px; }
            .header h1 { font-size: 1.5em; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📰 每日早报</h1>
            <div class="date">$DATE</div>
        </div>
        
        <div class="content">
            <div class="section">
                <h2>🌤️ 天气信息</h2>
                <div class="weather">
                    $weather
                </div>
            </div>
            
            <div class="section">
                <h2>🌍 国外科技新闻 (Hacker News)</h2>
                <ul>
$HN_LIST
                </ul>
            </div>
            
            <div class="section">
                <h2>🇨🇳 国内科技新闻 (量子位)</h2>
                <ul>
$QBITAI_LIST
                </ul>
            </div>
            
            <div class="section">
                <h2>📋 今日待办</h2>
                <ul class="todo">
                    <li>[ ] 9:00 - 查看今日新闻摘要</li>
                    <li>[ ] 10:00 - 处理工作事项</li>
                    <li>[ ] 14:00 - 下午任务跟进</li>
                    <li>[ ] 18:00 - 每日总结</li>
                </ul>
            </div>
        </div>
        
        <div class="footer">
            <div class="timestamp">🕐 更新时间: $(date "+%Y-%m-%d %H:%M:%S")</div>
            <div class="credit">🤖 自动生成 by OpenClaw Daily News Skill</div>
        </div>
    </div>
</body>
</html>
EOF
    
    log_success "HTML 报告已生成: $DAILY_NEWS_FILE"
}

# ==========================================
# 5. Git 提交
# ==========================================
git_commit() {
    if [ "$SKIP_GIT" = "1" ]; then
        log_info "跳过 Git 提交"
        return 0
    fi
    
    log_info "Git 提交..."
    
    cd "$SKILL_DIR"
    
    # 检查是否有更改
    if git status --porcelain | grep -q .; then
        git add .
        git commit -m "📰 daily: Update news briefing for $DATE"
        
        if [ $? -eq 0 ]; then
            log_success "Git 提交成功"
        else
            log_error "Git 提交失败"
            return 1
        fi
    else
        log_info "没有文件更改，跳过 Git 提交"
    fi
}

# ==========================================
# 6. 推送到飞书（可选）
# ==========================================
push_to_feishu() {
    if [ "$SKIP_FEISHU" = "1" ]; then
        log_info "跳过飞书推送（默认）"
        return 0
    fi
    
    log_info "推送到飞书..."
    
    # 检查配置文件
    if [ ! -f "$SCRIPT_DIR/feishu-config.sh" ]; then
        log_warning "飞书配置不存在，跳过推送"
        return 0
    fi
    
    source "$SCRIPT_DIR/feishu-config.sh"
    
    # 这里需要实现飞书 API 调用
    # TODO: 实现 feishu_push.sh
    log_warning "飞书推送功能需要配置 API，详见 references/integration.md"
}

# ==========================================
# 主流程
# ==========================================
main() {
    echo ""
    echo "=========================================="
    echo "🚀 开始生成每日早报..."
    echo "📅 日期: $DATE"
    echo "📁 输出目录: $OUTPUT_DIR"
    echo "=========================================="
    echo ""
    
    # 1. 获取天气
    WEATHER=$(get_weather)
    log_success "天气信息获取完成"
    
    # 2. 获取 Hacker News
    HN_NEWS=$(get_hacker_news)
    log_success "Hacker News 获取完成"
    
    # 3. 获取量子位
    QBITAI_NEWS=$(get_qbitai_news)
    log_success "量子位新闻获取完成"
    
    # 4. 生成 HTML
    generate_html_report "$WEATHER" "$HN_NEWS" "$QBITAI_NEWS"
    
    # 5. Git 提交
    git_commit
    
    # 6. 飞书推送（可选）
    push_to_feishu
    
    echo ""
    echo "=========================================="
    echo "✅ 每日早报生成完成！"
    echo "📄 文件位置: $DAILY_NEWS_FILE"
    echo "=========================================="
    echo ""
}

# 运行主流程
main
