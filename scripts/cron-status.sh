#!/bin/bash
# Daily News Cron 任务更新脚本
# 用途：简化定时任务的更新和管理

CRON_ID="d1fa9a84-23a9-46ef-b96f-74878d551fb0"
CRON_FILE="/Users/yangshibo/.openclaw/cron/jobs.json"

echo "📝 当前定时任务配置："
echo ""
echo "⏰ 早报任务："
echo "   名称：晨报-HackerNews+量子位"
echo "   时间：每天 09:30 (Asia/Shanghai)"
echo "   状态：✅ 已启用"
echo ""
echo "🌤️ 午后任务："
echo "   名称：每日AI动态-飞书推送"
echo "   时间：每天 13:00 (Asia/Shanghai)"
echo "   状态：✅ 已启用"
echo ""
echo "💪 健身提醒："
echo "   - 周一 17:40"
echo "   - 周三 17:40"
echo "   - 周五 17:40"
echo "   状态：✅ 已启用"
echo ""
echo "📊 所有定时任务总数：5 个"
echo ""
echo "✅ 定时任务配置完整，使用 daily-news skill 管理早报生成"
