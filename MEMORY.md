# 早报内容获取 - 最佳实践

## 数据源
- **国内新闻**：https://www.qbitai.com (量子位)
- **国外新闻**：https://news.ycombinator.com (Hacker News)

## 内容获取方法（优先级排序）

### 1. 国内网站 - 无需代理
```bash
# 方法1: curl 直接访问
curl -s "https://www.qbitai.com"

# 方法2: web_fetch
web_fetch(url="https://www.qbitai.com")
```

### 2. 国外网站 - 必须用代理
```bash
# 代理端口（Clash Verge）
export https_proxy=http://127.0.0.1:7897
export http_proxy=http://127.0.0.1:7897

# 方法1: curl + 代理
curl -s --proxy http://127.0.0.1:7897 "https://news.ycombinator.com/newest"

# 方法2: Serper 搜索（已配置 API Key）
curl -X POST "https://google.serper.dev/search" \
  -H "Content-Type: application/json" \
  -d '{"q": "site:news.ycombinator.com newest", "apiKey": "2c3135ef3a506a7e7cb53d0fb343bbe7921d2ff7"}'

# 方法3: 浏览器操作（如果代理可用）
browser(action="navigate", targetUrl="https://news.ycombinator.com/newest")
```

### 3. 通用方法
```bash
# 方法4: web_fetch（可能被屏蔽）
web_fetch(url="https://news.ycombinator.com/newest")

# 方法5: 如果 curl 超时，重新用代理尝试
curl -s --proxy http://127.0.0.1:7897 "https://news.ycombinator.com/newest"
```

## 故障排除流程

1. **curl 超时** → 用代理重试
2. **web_fetch 失败** → 尝试 curl + 代理
3. **代理无效** → 使用 Serper 搜索
4. **所有方法都失败** → 至少保证一个源有数据

## 关键教训

### ✅ 成功经验
- **代理是关键**：国外网站必须用代理（端口 7897）
- **curl + 代理** 最可靠
- **Serper 搜索** 作为备用方案（已配置 API Key）
- **多方法尝试**：不要放弃，总有一个方法有效

### ❌ 错误教训
- ❌ 忘记用代理导致国外网站全部超时
- ❌ 只依赖 cron 任务，没有手动备用方案
- ❌ 数据过期未更新（任务跳过时没有补偿机制）

## 今日数据示例（2026-02-08）

### Hacker News 最新新闻
1. Search NYC open data - 1 point
2. Michael Pollan Says Humanity Is About to Undergo a Revolutionary Change - 2 points
3. Show HN: Grovia – Long-Range Greenhouse Monitoring System - 1 point
4. Agent News Chat – AI agents talk to each other about the news - 2 points
5. Psychometric Comparability of LLM-Based Digital Twins (arxiv) - 1 point
6. The success of 'natural language programming' - 1 point
7. Code only says what it does - 2 points
8. Mind the GAAP Again - 1 point

### 量子位国内新闻（待获取）

## 下次执行早报时的检查清单

- [ ] 检查天气（curl -s "wttr.in/上海?format=3"）
- [ ] 获取国外新闻（curl + 代理）
- [ ] 获取国内新闻（curl 或 web_fetch）
- [ ] 更新 HTML 文件
- [ ] 推送到飞书
- [ ] 提交 git commit

---

# Vercel + GitHub 部署 - 教训总结（2026-02-08）

## 问题症状
- GitHub 推送代码后，Vercel 没有自动部署
- 通过 API 检查部署历史，停留在 2 天前
- Vercel 配置文件显示 GitHub 已连接，但无新部署触发

## 根本原因
Git 作者邮箱和 Vercel 团队权限不匹配：
```
Error: Git author yangshibo1026@qq.com must have access 
to the team tom's projects on Vercel to create deployments.
```

## Git Author 权限问题
- Git 提交用户：`yangshibo1026@qq.com`
- Vercel 团队账号：`tom's projects`（邮箱 `moran596268641@gmail.com`）
- GitHub 仓库是私有的，Vercel 需要 Git 作者有权限访问仓库

## 解决方案

### 方法 1：更改 Git Author（推荐）
```bash
# 检查当前 Git 配置
git config user.email
git config user.name

# 更改 Git author 为 Vercel 团队邮箱
git config user.email "moran596268641@gmail.com"
git config user.name "tom"

# 重新提交并推送
git add .
git commit -m "fix: Change git author to match Vercel team"
git push origin main

# 使用 Vercel CLI 部署
npx vercel --token=$VERCEL_TOKEN --yes
```

### 方法 2：在 Vercel 后台添加协作者
1. 打开：https://vercel.com/toms-projects-f8f5147f/workspace/settings/members
2. 点击 "Invite"
3. 添加 Git 作者邮箱为协作者
4. 至少需要 Developer 或 Observer 权限

### 方法 3：删除重建项目（彻底解决）
如果存在部署方式冲突（旧项目通过 CLI 创建，新连接 GitHub）：
1. 在 Vercel 后台删除旧项目
2. 删除 GitHub 仓库
3. 重新通过 "Add New Project" → 选择 GitHub 仓库
4. 这样会创建一个纯粹通过 GitHub webhook 触发的项目

## Vercel 部署方式（4 种）
1. **Git** - 推送代码自动触发（推荐）
2. **Vercel CLI** - `npx vercel --token=TOKEN --yes`
3. **Deploy Hooks** - 通过 URL 触发
4. **REST API** - 通过 API 触发

## Git 作者邮箱配置检查清单
- [ ] Git 作者邮箱必须与 Vercel 团队成员邮箱匹配
- [ ] Git 作者必须有权限访问 GitHub 私有仓库
- [ ] 推送后等待 1-2 分钟让 Vercel 检测
- [ ] 使用 Vercel CLI 部署可以快速验证权限：`npx vercel --token=TOKEN --yes`

## Vercel API 查询命令
```bash
# 检查项目 Git 配置
curl "https://api.vercel.com/v6/projects/workspace" \
  -H "Authorization: Bearer $VERCEL_TOKEN" | python3 -c "import json; d=json.load(sys.stdin); print(json.dumps(d.get('link',{}), indent=2))"

# 检查最近部署
curl "https://api.vercel.com/v6/deployments?projectId=prj_XXX&limit=3" \
  -H "Authorization: Bearer $VERCEL_TOKEN"

# 触发部署（如果权限正确）
npx vercel --token=$VERCEL_TOKEN --yes
```

## 成功验证
- ✅ Git author 权限正确后，Vercel CLI 部署成功
- ✅ 部署 URL: workspace-c3gvpeaeo-toms-projects-f8f5147f.vercel.app
- ✅ GitHub webhook 自动触发机制应该正常工作
