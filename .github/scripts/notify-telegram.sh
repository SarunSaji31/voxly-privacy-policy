#!/bin/bash
# Posts one message to the owner's Voxlykeys-CI-alerts Telegram channel.
#
#   .github/scripts/notify-telegram.sh "<b>Title</b>
#   detail line
#   <a href=\"https://...\">View run ↗</a>"
#
# The text is Telegram HTML. Anything that did not come from the workflow
# itself (commit messages, PR titles, branch names) must go through
# tg-escape.sh first, so a "<" in a title cannot break the markup.
#
# Needs TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID in the environment. A missing
# secret or a Telegram outage is a warning, never a failure: an alert must not
# be the thing that breaks a release or a deploy.
set -uo pipefail
text="${1:?usage: notify-telegram.sh <html>}"
if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
  echo "::warning::TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID not set; no alert sent"
  exit 0
fi
body=$(mktemp)
trap 'rm -f "$body"' EXIT

# $1 = text, $2 = parse mode, empty for plain text.
send() {
  code=$(curl -sS -o "$body" -w '%{http_code}' --max-time 15 \
    --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
    --data-urlencode "text=$1" \
    ${2:+--data "parse_mode=$2"} \
    --data "disable_web_page_preview=true" \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage") || code=000
}

send "$text" HTML
# Markup Telegram cannot parse must not cost the alert: resend it as plain
# text, links kept as "label: url".
if [ "$code" = 400 ] && grep -q "can't parse entities" "$body"; then
  plain=$(printf '%s' "$text" | sed -E 's#<a href="([^"]*)">([^<]*)</a>#\2: \1#g; s/<[^>]+>//g; s/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g')
  send "$plain" ""
fi
if [ "$code" = 200 ]; then
  echo "alert sent"
else
  # Telegram's own reason ("chat not found", "bot is not a member..."), which
  # names the fix; the number alone does not. It never contains the token.
  reason=$(grep -o '"description":"[^"]*"' "$body" | cut -d'"' -f4)
  echo "::warning::Telegram answered ${code}${reason:+: $reason}; no alert sent"
fi
exit 0
