# Daily News Repository

每日 AI 新闻早报和午后 Reddit 洞察自动生成系统。

## Structure

```
daily-news/
├── morning/
│   ├── today.html          # 当日早报（每次覆盖）
│   └── old/                # 历史归档
│       └── YYYY-MM/       # 按月份归类
├── afternoon/
│   ├── today.html         # 当日午后（每次覆盖）
│   └── old/               # 历史归档
│       └── YYYY-MM/       # 按月份归类
```

## URLs

| Page | URL |
|------|-----|
| 📰 Morning | https://daily-news.vercel.app/ |
| 🌤️ Afternoon | https://daily-news.vercel.app/afternoon |

## Daily Workflow

1. **生成当日文件**: 运行 `daily-news.sh` 脚本
2. **自动归档**: 脚本自动将昨日文件归档到 `old/YYYY-MM/`
3. **Git 提交**: 自动提交并推送
4. **Vercel 部署**: 自动部署更新

## Files to Commit

- `morning/today.html` - 当日早报
- `afternoon/today.html` - 当日午后
- `old/*` - 历史归档文件

## Archives

历史文件按月份归档在 `old/YYYY-MM/` 目录中，自动由脚本管理。

## Deploy

自动部署到 Vercel，连接 GitHub 仓库 `code-nailao/daily-news`。

