#!/usr/bin/env bash
# Install the pre-push hook into an automation repo so the gate runs automatically.
# Usage: scripts/install-pre-push-hook.sh /path/to/staffinc-automation

set -euo pipefail

REPO="${1:-}"
[ -n "$REPO" ] || { echo "usage: $0 <path-to-repo>"; exit 2; }
[ -d "$REPO/.git" ] || { echo "not a git repo: $REPO"; exit 2; }

WORKFLOW_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GATE="$WORKFLOW_DIR/scripts/pre-push-review.sh"
HOOK="$REPO/.git/hooks/pre-push"

[ -f "$GATE" ] || { echo "gate not found: $GATE"; exit 2; }

cat > "$HOOK" <<EOF
#!/usr/bin/env bash
exec "$GATE" "\${PRE_PUSH_BASE:-origin/develop}"
EOF

chmod +x "$HOOK"
echo "installed: $HOOK -> $GATE"
echo "override base with: PRE_PUSH_BASE=origin/main git push"
