---
name: daily-news
description: Generate daily news briefing with weather, tech news from Hacker News and 量子位, create HTML report and push to Feishu. Perfect for morning news digest automation. Use keywords: "生成早报", "daily news", "今日新闻", "morning briefing".
---

# 📰 Daily News Briefing Skill

Generate comprehensive daily news briefing with automated data collection, HTML report generation, and Git/Feishu sync.

## Quick Start

```bash
# 进入 skill 目录
cd ~/.openclaw/skills/daily-news

# 运行完整工作流
./scripts/daily-news.sh

# 或指定日期
DATE=2026-02-10 ./scripts/daily-news.sh
```

## What It Does

1. **🌤️ Fetches Weather** - Gets Shanghai weather via wttr.in (configurable)
2. **🌍 Collects Hacker News** - Scrapes top 5 tech news from Hacker News (via proxy)
3. **🇨🇳 Collects Domestic News** - Gets tech news from 量子位 (qbitai.com)
4. **📄 Generates HTML Report** - Creates beautiful responsive HTML briefing
5. **🔄 Git Sync** - Auto-commits changes with timestamp (optional)
6. **📱 Feishu Integration** - Ready for document push (config needed)

## File Structure

```
daily-news/
├── SKILL.md                    # This file
├── scripts/
│   ├── daily-news.sh          # Main executable script
│   ├── init-env.sh            # Environment setup (optional)
│   └── feishu-push.sh         # Feishu push script (optional)
├── references/
│   ├── cron-config.md         # Cron setup guide
│   ├── integration.md         # Integration with other AI tools
│   └── troubleshooting.md     # Common issues and solutions
└── assets/
    └── templates/
        └── daily-news.html    # HTML template
```

## Dependencies

| Dependency | Required | Description |
|------------|----------|-------------|
| `curl` | ✅ Yes | HTTP requests |
| `git` | ✅ Yes | Version control |
| `bash` | ✅ Yes | Shell execution |
| Proxy (127.0.0.1:7897) | ⚠️ Optional | For Hacker News access |
| `web_fetch` | ⚠️ Optional | Fallback for qbitai.com |

## Usage

### Basic Usage

```bash
cd ~/.openclaw/skills/daily-news/scripts
./daily-news.sh
```

### Advanced Options

```bash
# Generate for specific date
DATE=2026-02-10 ./daily-news.sh

# Skip Git commit
SKIP_GIT=1 ./daily-news.sh

# Custom output directory
OUTPUT_DIR=/tmp/reports ./daily-news.sh

# Verbose output
VERBOSE=1 ./daily-news.sh

# Combined options
DATE=2026-02-10 SKIP_GIT=1 VERBOSE=1 ./daily-news.sh
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATE` | Today | Target date (YYYY-MM-DD) |
| `WEATHER_CITY` | 上海 | City for weather |
| `PROXY` | http://127.0.0.1:7897 | HTTP proxy |
| `SKIP_GIT` | 0 | Skip git commit (1=yes) |
| `SKIP_FEISHU` | 1 | Skip Feishu push (0=yes) |
| `OUTPUT_DIR` | .. | Output directory |
| `VERBOSE` | 0 | Verbose logging (1=yes) |

## Output

**Generated Files:**
```
daily-news.html          # Main HTML report
daily-news-{DATE}.html   # Dated report (if OUTPUT_DIR set)
```

**Report Sections:**
- 📅 Date header
- 🌤️ Weather (with icons)
- 🌍 Hacker News (top 5)
- 🇨🇳 量子位 News (top 5)
- 📋 Today's todo list
- 🕐 Timestamp
- 📊 Git commit reference

## Integration

### With OpenClaw

Trigger by saying:
- "生成今日早报"
- "daily news"
- "今日新闻"
- "早报"

### With Other AI Tools

```bash
# Claude Code
bash /path/to/daily-news/scripts/daily-news.sh

# Cursor
# Add to Terminal: bash /path/to/daily-news/scripts/daily-news.sh

# Cron (see references/cron-config.md)
0 8 * * * /bin/bash /path/to/daily-news/scripts/daily-news.sh
```

### Standalone Usage

Copy the entire `daily-news/` folder to any location:

```bash
# Clone to new location
cp -r ~/.openclaw/skills/daily-news ~/my-daily-news

# Run from new location
cd ~/my-daily-news
./scripts/daily-news.sh
```

## Configuration

### Weather Location

Edit in `scripts/daily-news.sh`:
```bash
WEATHER_CITY="北京"  # Change city
```

### Proxy Settings

Edit in `scripts/daily-news.sh`:
```bash
PROXY="http://127.0.0.1:7897"  # Your proxy
```

### Feishu Integration

1. Get Feishu document token
2. Create `scripts/feishu-config.sh`:
```bash
#!/bin/bash
FEISHU_DOC_TOKEN="your-doc-token"
FEISHU_APP_ID="your-app-id"
FEISHU_APP_SECRET="your-app-secret"
```
3. Run with `SKIP_FEISHU=0`

## Troubleshooting

See `references/troubleshooting.md` for:
- Hacker News not loading
- Quantum Wei (量子位) failed
- Git commit errors
- HTML generation issues

## Advanced Customization

### Adding News Sources

Edit `scripts/daily-news.sh`, add to `main()`:

```bash
# Add new source function
get_custom_news() {
    echo "Getting custom news..."
    curl -s "https://example.com/news" 2>/dev/null
}

# Call in main
CUSTOM_NEWS=$(get_custom_news)
```

### Modifying HTML Template

Edit `assets/templates/daily-news.html`:
- Change CSS styles
- Add new sections
- Modify layout
- Update color scheme

### Adding New Sections

Edit `generate_html_report()` in `scripts/daily-news.sh`:

```bash
add_section() {
    local title="$1"
    local content="$2"
    # Add section logic
}
```

## Performance

| Step | Time | Notes |
|------|------|-------|
| Weather | ~500ms | Fast response |
| Hacker News | ~1-2s | With proxy |
| 量子位 | ~1s | Direct access |
| HTML Gen | <100ms | Template-based |
| Git Commit | <500ms | Local repo |
| **Total** | ~3-4s | Full workflow |

## Git Workflow

The script automatically:
1. Checks for changes
2. Stages all files
3. Commits with message: `📰 daily: Update news for YYYY-MM-DD`
4. Ready for `git push`

To push automatically, uncomment in `scripts/daily-news.sh`:
```bash
# git push origin main
```

## Security Notes

- Proxy credentials not hardcoded
- HTML output sanitized
- Git commits are local
- Feishu API requires separate auth

## References

| File | Description |
|------|-------------|
| `references/cron-config.md` | Cron setup and automation |
| `references/integration.md` | Integration with other AI tools |
| `references/troubleshooting.md` | Common issues and solutions |

## Future Enhancements

- [ ] Email notification
- [ ] Multi-language support
- [ ] RSS feed generation
- [ ] Image attachment parsing
- [ ] Social media sharing
- [ ] Sentiment analysis
- [ ] Trend detection
- [ ] JSON output mode

## Credits

- Weather: wttr.in
- News: Hacker News + 量子位
- Design: Bootstrap-inspired
- Automation: OpenClaw Skill Creator
