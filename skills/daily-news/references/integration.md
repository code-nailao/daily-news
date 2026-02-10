# Integration Guide

## Overview

This guide explains how to integrate the daily-news skill with various AI tools and platforms.

## OpenClaw

### Automatic Trigger

The skill automatically activates when you use trigger keywords:
- "生成今日早报"
- "daily news"
- "今日新闻"
- "morning briefing"

### Manual Execution

```bash
cd ~/.openclaw/skills/daily-news
./scripts/daily-news.sh
```

### OpenClaw Cron

```bash
openclaw cron add \
  --name "daily-news-morning" \
  --schedule "cron: 0 8 * * *" \
  --message "生成每日早报" \
  --session isolated
```

## Claude Code

### Direct Execution

```bash
# Run in terminal
cd ~/path/to/daily-news
./scripts/daily-news.sh

# Output will be displayed in Claude Code terminal
```

### Integration with Claude Projects

Add to your Claude Code project:

```bash
# In project root
mkdir -p scripts
cp /path/to/daily-news/scripts/daily-news.sh scripts/

# Add to CLAUDE.md
## Daily News
Run `./scripts/daily-news.sh` to generate morning briefing.
```

## Cursor IDE

### Terminal Integration

1. Open Cursor terminal (⌃`)
2. Run:
```bash
cd /path/to/daily-news
./scripts/daily-news.sh
```

### Custom Command

Add to `settings.json`:

```json
{
  "terminal.integrated.shellArgs.linux": [],
  "terminal.integrated.shellArgs.osx": ["-l"],
  "terminal.integrated.env.osx": {
    "SKILL_DIR": "/path/to/daily-news"
  }
}
```

## VS Code

### Similar to Cursor

Use the integrated terminal:
```bash
cd /path/to/daily-news/scripts
./daily-news.sh
```

### Extension Suggestion

Use "Terminal Here" extension for quick access.

## Homebrew (macOS)

### Create Formula

```ruby
class DailyNews < Formula
  desc "Daily news briefing generator"
  homepage "https://github.com/yourusername/daily-news"
  url "https://github.com/yourusername/daily-news/archive/v1.0.0.tar.gz"
  sha256 "..."
  
  depends_on "curl"
  depends_on "git"
  
  def install
    bin.install "scripts/daily-news.sh" => "daily-news"
  end
end
```

### Install

```bash
brew install ./daily-news.rb
brew services start daily-news
```

## Docker

### Create Dockerfile

```dockerfile
FROM alpine:latest

RUN apk add --no-cache bash curl git

WORKDIR /app

COPY scripts/ scripts/
COPY assets/ assets/

RUN chmod +x scripts/daily-news.sh

CMD ["/app/scripts/daily-news.sh"]
```

### Build & Run

```bash
docker build -t daily-news .
docker run -v $(pwd)/output:/app daily-news
```

## GitHub Actions

### Workflow File

```yaml
name: Daily News

on:
  schedule:
    - cron: '0 8 * * *'  # 8 AM daily
  workflow_dispatch:

jobs:
  news:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup
        run: |
          chmod +x scripts/daily-news.sh
          
      - name: Generate News
        run: |
          ./scripts/daily-news.sh
          
      - name: Commit & Push
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add .
          git commit -m "📰 Update daily news - $(date +%Y-%m-%d)" || echo "No changes"
          git push
```

## Systemd (Linux)

### Create Service

```ini
# /etc/systemd/system/daily-news.service
[Unit]
Description=Daily News Briefing Generator
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash /path/to/daily-news/scripts/daily-news.sh
User=yourusername

[Install]
WantedBy=multi-user.target
```

### Create Timer

```ini
# /etc/systemd/system/daily-news.timer
[Unit]
Description=Run daily news at 8 AM

[Timer]
OnCalendar=*-*-* 8:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

### Enable & Start

```bash
sudo systemctl enable daily-news.timer
sudo systemctl start daily-news.timer
```

## Schedule with launchd (macOS)

### Create Plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.daily-news</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/path/to/daily-news/scripts/daily-news.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>8</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
```

### Install

```bash
mkdir -p ~/Library/LaunchAgents
cp com.user.daily-news.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.daily-news.plist
```

## API Integration

### REST API Wrapper

Create `api-server.sh`:

```bash
#!/bin/bash
# Simple API wrapper for daily-news

case "$1" in
    generate)
        ./scripts/daily-news.sh
        echo "{\"status\": \"success\", \"file\": \"$OUTPUT_DIR/daily-news.html\"}"
        ;;
    latest)
        cat "$OUTPUT_DIR/daily-news.html"
        ;;
    *)
        echo "Usage: $0 {generate|latest}"
        exit 1
        ;;
esac
```

### Use with curl

```bash
# Generate news
curl -X POST http://localhost:8080/daily-news/generate

# Get latest
curl http://localhost:8080/daily-news/latest
```

## Notification Integration

### Slack Notification

```bash
# Add to end of daily-news.sh
if [ -n "$SLACK_WEBHOOK" ]; then
    curl -s -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"📰 Daily news generated! File: $DAILY_NEWS_FILE\"}" \
        "$SLACK_WEBHOOK"
fi
```

### Email Notification

```bash
# Add to end of daily-news.sh
if [ -n "$EMAIL_TO" ]; then
    mail -s "Daily News - $DATE" "$EMAIL_TO" < "$DAILY_NEWS_FILE"
fi
```

## Environment Variables Summary

| Variable | Default | Description |
|----------|---------|-------------|
| `DATE` | Today | Target date |
| `WEATHER_CITY` | 上海 | Weather location |
| `PROXY` | http://127.0.0.1:7897 | HTTP proxy |
| `SKIP_GIT` | 0 | Skip git commit |
| `SKIP_FEISHU` | 1 | Skip Feishu push |
| `OUTPUT_DIR` | Skill dir | Output directory |
| `VERBOSE` | 0 | Verbose logging |
| `SLACK_WEBHOOK` | - | Slack webhook URL |
| `EMAIL_TO` | - | Email recipient |

## Troubleshooting

See `references/troubleshooting.md` for common issues.
