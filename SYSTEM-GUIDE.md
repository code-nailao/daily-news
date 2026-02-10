# 📰 Daily News System - 完整指南

## 🎯 系统概述

这是一个自动化的每日 AI 新闻早报系统，包括：
- 🤖 自动获取新闻（Hacker News + 量子位 + Serper 搜索）
- 📄 自动生成 HTML 报告
- 🔄 自动 Git 提交和归档
- 🌐 自动 Vercel 部署
- 📱 自动飞书推送（可选）

## 📁 目录结构

```
daily-news/
├── morning/                    # 早报目录
│   ├── today.html             # 当日早报（自动覆盖）
│   └── old/                   # 历史归档
│       └── YYYY-MM/
│           └── YYYY-MM-DD.html
├── afternoon/                 # 午后 Reddit 洞察
├── scripts/
│   ├── daily-news.sh         # 基础脚本
│   └── daily-news-full.sh    # 完整工作流脚本
│   └── cron-status.sh        # 定时任务状态
└── README.md                  # 本文档
```

## 🚀 快速开始

### 方式 1：使用完整工作流（推荐）

```bash
# 执行完整工作流
bash ~/.openclaw/skills/daily-news/scripts/daily-news-full.sh
```

### 方式 2：使用基础脚本

```bash
# 仅生成 HTML
cd ~/.openclaw/skills/daily-news/scripts
DATE=$(date +%Y-%m-%d) ./daily-news.sh
```

### 方式 3：手动执行（开发调试）

```bash
# 1. 获取数据
export https_proxy=http://127.0.0.1:7897
curl -s --proxy http://127.0.0.1:7897 "https://news.ycombinator.com/newest" > /tmp/hn.html

# 2. 生成 HTML
cd ~/.openclaw/workspace/project/daily-news
python3 generate_html.py

# 3. Git 提交
git add -A && git commit -m "📰 Update $(date +%Y-%m-%d)" && git push

# 4. 部署
npx vercel --token=$VERCEL_TOKEN --yes --prod
```

## ⏰ 定时任务配置

### 查看定时任务状态

```bash
# 查看所有定时任务
cron list

# 查看特定任务
cron status
```

### 定时任务列表

| 任务名称 | 执行时间 | 说明 |
|---------|---------|------|
| 晨报任务 | 每天 09:30 | 获取 Hacker News + 量子位，生成 HTML，Git 提交 |
| 午后任务 | 每天 13:00 | Reddit 洞察，飞书推送 |
| 健身提醒-周一 | 17:40 | 周一健身提醒 |
| 健身提醒-周三 | 17:40 | 周三健身提醒 |
| 健身提醒-周五 | 17:40 | 周五健身提醒 |

### 更新定时任务

定时任务通过 OpenClaw 的 cron 工具管理：

```bash
# 更新早报任务
cron update --id <task-id> --message "<新prompt>"

# 禁用任务
cron update --id <task-id> --enabled false

# 启用任务
cron update --id <task-id> --enabled true
```

## 🔧 配置项

### 必需的环境变量

```bash
# Git 配置
git config user.email "yangshibo1026@qq.com"
git config user.name "yangshibo"

# Vercel Token
export VERCEL_TOKEN="a3NEa7dxUKp4LWmwHz30nwXG"

# 代理配置
export https_proxy=http://127.0.0.1:7897
export http_proxy=http://127.0.0.1:7897

# Serper API Key（用于量子位搜索）
export SERPER_API_KEY="2c3135ef3a506a7e7cb53d0fb343bbe7921d2ff7"
```

### 可选配置文件

创建 `~/.clawrc` 或在脚本中设置：

```bash
# 天气城市
WEATHER_CITY="上海"

# 输出目录
OUTPUT_DIR="$HOME/.openclaw/workspace/project/daily-news"

# Git 提交消息模板
GIT_COMMIT_MSG="📰 Daily update: $(date +%Y-%m-%d)"
```

## 📊 工作流详解

### 1️⃣ 数据获取阶段

**Hacker News**：
```bash
curl -s --proxy http://127.0.0.1:7897 "https://news.ycombinator.com/newest"
```

**量子位（量子位）**：
```bash
curl -X POST "https://google.serper.dev/search" \
  -H "Content-Type: application/json" \
  -d '{"q": "site:qbitai.com AI news", "apiKey": "..."}'
```

**天气数据**：
```bash
curl -s "wttr.in/上海?format=3"
```

### 2️⃣ HTML 生成阶段

模板位置：
- 早报：`~/.openclaw/workspace/project/daily-news/morning/today.html`
- 午后：`~/.openclaw/workspace/project/daily-news/afternoon/today.html`

使用 Python 脚本生成，特点：
- Apple 风格的极简设计
- 响应式布局
- 平滑动画效果

### 3️⃣ Git 管理阶段

自动执行：
1. 创建 `morning/old/YYYY-MM/` 目录
2. 移动昨日文件到归档目录
3. 提交今日 `today.html`
4. 推送到 GitHub

### 4️⃣ Vercel 部署阶段

自动触发：
- Git push 触发 webhook
- Vercel 自动检测并部署
- 约 30 秒完成部署

### 5️⃣ 飞书推送阶段（可选）

消息模板：
```
🌤️ **Claw 的早安问候**

**老板早上好呀～**

📰 **AI Daily - 2026-02-10**

今日早报已更新！
- 🌍 全球科技动态
- 🇨🇳 中国 AI 动态
- 🦅 Hacker News 热门讨论

🔗 https://daily-news.vercel.app/
```

## 🛠️ 故障排除

### 问题 1：Hacker News 无法访问

**症状**：curl 超时或连接失败

**解决方案**：
```bash
# 检查代理
curl -s --proxy http://127.0.0.1:7897 "https://news.ycombinator.com"

# 重启代理
# 检查 Clash Verge 是否运行
```

### 问题 2：量子位获取失败

**症状**：Serper 返回空结果

**解决方案**：
```bash
# 验证 API Key
curl -X POST "https://google.serper.dev/search" \
  -H "Content-Type: application/json" \
  -d '{"q": "test", "apiKey": "YOUR_KEY"}'

# 使用备用数据源
curl -s "https://www.qbitai.com" | grep -o '<a href="[^"]*"' | head -10
```

### 问题 3：Git 提交失败

**症状**：`nothing to commit` 或权限错误

**解决方案**：
```bash
# 检查 Git 状态
git status

# 检查远程仓库
git remote -v

# 重新配置 Git
git config user.email "yangshibo1026@qq.com"
git config user.name "yangshibo"
```

### 问题 4：Vercel 部署失败

**症状**：部署超时或错误

**解决方案**：
```bash
# 手动触发部署
npx vercel --token=$VERCEL_TOKEN --yes --prod

# 检查 Vercel 后台
# 访问：https://vercel.com/yangshibos-projects/daily-news
```

### 问题 5：飞书消息发送失败

**症状**：消息工具返回错误

**解决方案**：
```bash
# 验证用户 ID
# 检查 channel 配置
# 查看 OpenClaw 日志
```

## 📈 性能指标

| 步骤 | 典型耗时 | 说明 |
|------|---------|------|
| 数据获取 | 2-3s | 包括 HN 和量子位 |
| HTML 生成 | <1s | Python 脚本 |
| Git 操作 | 1-2s | 提交和推送 |
| Vercel 部署 | 15-30s | 自动触发 |
| 飞书推送 | <1s | API 调用 |
| **总计** | **20-40s** | 完整工作流 |

## 🔐 安全注意事项

1. **API Keys**：不要硬编码在脚本中，使用环境变量
2. **代理配置**：确保代理安全，避免明文传输
3. **Git 权限**：使用 Personal Access Token 或 SSH Key
4. **飞书权限**：定期检查应用权限

## 📚 相关资源

- **项目仓库**：`code-nailao/daily-news`
- **Vercel 项目**：`yangshibos-projects/daily-news`
- **访问地址**：https://daily-news.vercel.app/
- **Skill 位置**：`~/.openclaw/skills/daily-news`

## 🤝 贡献指南

欢迎改进此系统！可以通过以下方式：

1. **优化模板**：改进 HTML/CSS 设计
2. **增强脚本**：添加新功能或优化性能
3. **完善文档**：修复错误或补充内容

## 📄 许可证

本项目使用 MIT License。

---

**维护者**：Claw 🤖  
**最后更新**：2026-02-10
