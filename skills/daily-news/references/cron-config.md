# Cron Configuration Guide

## Setup Cron Job

### 1. Edit Crontab

```bash
crontab -e
```

### 2. Add Entry

Add one of the following entries:

**Daily at 7:30 AM:**
```bash
30 7 * * * /bin/bash /path/to/daily-news/scripts/daily-news.sh >> /path/to/logs/daily-news.log 2>&1
```

**Every Hour:**
```bash
0 * * * * /bin/bash /path/to/daily-news/scripts/daily-news.sh >> /path/to/logs/daily-news.log 2>&1
```

**Weekdays at 8:00 AM:**
```bash
0 8 * * 1-5 /bin/bash /path/to/daily-news/scripts/daily-news.sh >> /path/to/logs/daily-news.log 2>&1
```

### 3. Create Log Directory

```bash
mkdir -p /path/to/logs
touch /path/to/logs/daily-news.log
```

### 4. Verify Installation

```bash
# List cron jobs
crontab -l

# Test run
/bin/bash /path/to/daily-news/scripts/daily-news.sh

# Check log
cat /path/to/logs/daily-news.log
```

## Cron Format

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday=0)
│ │ │ │ │
│ │ │ │ │
* * * * * command
```

## Examples

| Schedule | Cron Expression |
|----------|-----------------|
| Every minute | `* * * * *` |
| Every hour | `0 * * * *` |
| Every day at midnight | `0 0 * * *` |
| Every Monday at 9 AM | `0 9 * * 1` |
| First day of month | `0 0 1 * *` |
| Weekdays only | `0 9 * * 1-5` |

## Manage Cron Jobs

```bash
# Edit crontab
crontab -e

# List current jobs
crontab -l

# Remove all jobs
crontab -r

# Backup crontab
crontab -l > backup-cron.txt

# Restore from backup
crontab backup-cron.txt
```

## Troubleshooting

### Cron Not Running?

1. Check cron service status:
   ```bash
   # macOS
   sudo launchctl list | grep cron
   
   # Linux
   systemctl status cron
   ```

2. Start cron service:
   ```bash
   # macOS
   sudo launchctl load -w /System/Library/LaunchDaemons/com.vix.cron.plist
   
   # Linux
   sudo systemctl start cron
   sudo systemctl enable cron
   ```

### Permission Issues?

```bash
# Make script executable
chmod +x /path/to/daily-news/scripts/daily-news.sh

# Check file permissions
ls -la /path/to/daily-news/scripts/
```

### Environment Variables?

Cron runs with minimal environment. Add to top of crontab:

```bash
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
HOME=/Users/yourusername
```

Or source profile in script:

```bash
#!/bin/bash
source ~/.bash_profile  # or ~/.zshrc
# ... rest of script
```

## Integration with OpenClaw Cron

OpenClaw has built-in cron support:

```bash
# Add job via OpenClaw
openclaw cron add --name "daily-news" \
  --schedule "cron: 0 8 * * *" \
  --message "生成每日早报" \
  --session main
```

See OpenClaw docs for details.
