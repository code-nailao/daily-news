# Troubleshooting Guide

## Common Issues

### 1. Hacker News Not Loading

**Symptom:**
```
[ERROR] Hacker News 获取完全失败
```

**Solutions:**

#### Check Proxy
```bash
# Test proxy connection
curl -v --proxy http://127.0.0.1:7897 https://news.ycombinator.com

# Verify proxy is running
ps aux | grep -i proxy
```

#### Direct Connection (Fallback)
The script should automatically try direct connection. If not:

```bash
# Temporarily disable proxy
PROXY="" ./scripts/daily-news.sh
```

#### Check Network
```bash
# Test internet connectivity
ping -c 3 news.ycombinator.com

# Check DNS
nslookup news.ycombinator.com
```

**Common Causes:**
- Proxy not running
- Wrong proxy port (try 7890 instead of 7897)
- Network firewall blocking

---

### 2. 量子位 (qbitai.com) Failed

**Symptom:**
```
[ERROR] 量子位获取完全失败
```

**Solutions:**

#### Check Direct Access
```bash
# Test connection
curl -v https://www.qbitai.com

# Check for 403 Forbidden
curl -I https://www.qbitai.com
```

#### User-Agent Issue
量子位 may block certain user-agents. Edit `scripts/daily-news.sh`:

```bash
# Change curl to include user-agent
curl -s -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    "https://www.qbitai.com"
```

#### Use web_fetch Fallback
The script should try `web_fetch` as fallback:

```bash
# Install web_fetch tool
npm install -g @anthropic-ai/web-fetch
```

**Common Causes:**
- Site blocking (403)
- Cloudflare protection
- Slow response timeout

---

### 3. Weather Not Loading

**Symptom:**
```
☁️ 上海: 天气信息获取失败
```

**Solutions:**

#### Check wttr.in Service
```bash
# Test directly
curl -s "wttr.in/上海?format=3"

# Check service status
curl -s "https://wttr.in/:help" | head -20
```

#### Alternative Weather Sources
Edit `scripts/daily-news.sh` to use different source:

```bash
# Open-Meteo API (free, no key)
WEATHER=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=31.2304&longitude=121.4737&current_weather=true" | \
    grep -oP '"temperature":\s*\K[^,]+')
echo "上海: ${WEATHER}°C"
```

**Common Causes:**
- wttr.in service down
- Network blocking
- Timeout too short

---

### 4. Git Commit Failed

**Symptom:**
```
error: 'skills/humanizer/' does not have a commit checked out
fatal: adding files failed
```

**Solutions:**

#### Check Git Submodules
```bash
# Check for submodules
git submodule status

# Initialize submodules
git submodule update --init --recursive
```

#### Fix Broken Symlinks
```bash
# Find broken symlinks
find . -type l ! -exec test -e {} \; -print

# Remove broken links
find . -type l ! -exec test -e {} \; -delete
```

#### Reset Git State
```bash
# Stash changes
git stash

# Pull latest
git pull

# Re-apply changes
git stash pop
```

#### Skip Git
```bash
# Run without git
SKIP_GIT=1 ./scripts/daily-news.sh
```

**Common Causes:**
- Broken symlinks in workspace
- Uninitialized git submodules
- Merge conflicts

---

### 5. HTML Generation Failed

**Symptom:**
```
HTML 报告生成失败
```

**Solutions:**

#### Check File Permissions
```bash
# Make script executable
chmod +x scripts/daily-news.sh

# Check output directory writable
touch output/test.txt
rm output/test.txt
```

#### Check Disk Space
```bash
df -h
```

#### Check Template Syntax
```bash
# Validate HTML
cat daily-news.html | head -20

# Check for missing variables
grep -n '\$\{' daily-news.html
```

**Common Causes:**
- Disk full
- Permission issues
- Missing template variables

---

### 6. Output File Not Found

**Symptom:**
```
File not found: daily-news.html
```

**Solutions:**

#### Check Output Directory
```bash
# List files
ls -la

# Check configured output dir
echo "Output dir: $OUTPUT_DIR"
```

#### Specify Output Directory
```bash
OUTPUT_DIR=$(pwd) ./scripts/daily-news.sh
```

#### Use Absolute Path
```bash
OUTPUT_DIR=/Users/username/daily-news ./scripts/daily-news.sh
```

---

### 7. Cron Job Not Running

**Symptom:**
Cron job runs but no output.

**Solutions:**

#### Check Cron Service
```bash
# macOS
sudo launchctl list | grep cron

# Linux
systemctl status cron
```

#### Check Cron Logs
```bash
# Linux
grep CRON /var/log/syslog

# macOS
log show --predicate 'eventMessage CONTAINS "cron"' --last 1h
```

#### Full Path in Cron
```bash
# Use absolute paths in crontab
0 8 * * * /bin/bash /full/path/to/daily-news/scripts/daily-news.sh >> /full/path/to/log.log 2>&1
```

#### Environment in Cron
```bash
# Add to crontab
PATH=/usr/local/bin:/usr/bin:/bin
HOME=/Users/username
0 8 * * * /bin/bash /full/path/to/daily-news/scripts/daily-news.sh >> /path/to/log.log 2>&1
```

---

### 8. Proxy Not Working

**Symptom:**
Hacker News loads but returns unexpected content.

**Solutions:**

#### Test Proxy
```bash
# Check proxy response
curl -s --proxy http://127.0.0.1:7897 https://ifconfig.me

# Compare with direct
curl -s https://ifconfig.me
```

#### Different Proxy Port
```bash
# Try port 7890
PROXY="http://127.0.0.1:7890" ./scripts/daily-news.sh

# Or port 1080 (SOCKS5)
PROXY="socks5://127.0.0.1:1080" ./scripts/daily-news.sh
```

#### No Proxy
```bash
PROXY="" ./scripts/daily-news.sh
```

---

### 9. Verbose Debug Mode

**Enable Debug Output:**

```bash
VERBOSE=1 ./scripts/daily-news.sh
```

**Check Script Variables:**

```bash
# Add debug to script
echo "DATE=$DATE"
echo "PROXY=$PROXY"
echo "OUTPUT_DIR=$OUTPUT_DIR"
```

---

### 10. Get Help

If issue persists:

1. Check logs:
   ```bash
   tail -50 daily-news.log
   ```

2. Run with verbose:
   ```bash
   VERBOSE=1 SKIP_GIT=1 ./scripts/daily-news.sh
   ```

3. Report issue with:
   - OS version (`uname -a`)
   - Error message
   - Verbose output
   - Environment variables

---

## Performance Issues

### Slow Execution

**Check:**
```bash
# Time each step
time ./scripts/daily-news.sh
```

**Optimize:**
- Reduce proxy timeout
- Limit news items (change from 5 to 3)
- Disable git commit (`SKIP_GIT=1`)

### High Memory Usage

```bash
# Check memory
top -l 1 | head -10

# Check specific process
ps aux | grep daily-news
```

---

## Still Have Issues?

1. Search existing issues
2. Create new issue with:
   - Error message
   - OS and version
   - Reproduction steps
   - Verbose output
