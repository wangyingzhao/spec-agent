#!/bin/bash
# notify-wecom.sh <消息内容>
# 读取 ~/.claude/platform-sdd.setting.json 中的 wecom_webhook，发送企微通知
# 若 webhook 为空则静默退出，不影响主流程

SETTING_FILE="$HOME/.claude/platform-sdd.setting.json"
[ -f "$SETTING_FILE" ] || exit 0

WEBHOOK=$(python3 -c "import json,sys; d=json.load(open('$SETTING_FILE')); print(d.get('wecom_webhook',''))" 2>/dev/null)
[ -z "$WEBHOOK" ] && exit 0

MSG="${1:-SDD implement 完成}"

curl -s "$WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"$MSG\"}}"
