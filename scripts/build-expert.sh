#!/usr/bin/env bash
# 难题顾问 · 破疑 —— 构建脚本
#
#   ./scripts/build-expert.sh           # 组装 → 校验 → 注册 → 打包
#   ./scripts/build-expert.sh --bump    # 版本号 +1，再走上面全部流程
#   ./scripts/build-expert.sh --check   # 只比对技能源与安装目录，不改文件
#
# 源码都在这个仓库里：skill/ 是技能源，expert/ 是专家源码。
# 构建时两者合并成完整专家包，装进 WorkBuddy 的专家目录。

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_SRC="$REPO/skill/modern-thinking-tools"
EXPERT_SRC="$REPO/expert"
PLUGIN_JSON="$EXPERT_SRC/.codebuddy-plugin/plugin.json"
OUT_DIR="$REPO/dist"

INSTALL="$HOME/.workbuddy/plugins/marketplaces/my-experts/plugins/problem-advisor"

# ---------- 定位官方脚本 ----------
TOOLKIT_DIR=""
for cand in "/d/Programs/WorkBuddy/resources/app.asar.unpacked/resources/plugins/workbuddy-builtin/skills/expert-manager" \
            "/c/Programs/WorkBuddy/resources/app.asar.unpacked/resources/plugins/workbuddy-builtin/skills/expert-manager"; do
  if [ -d "$cand/scripts" ]; then TOOLKIT_DIR="$cand"; break; fi
done
if [ -z "$TOOLKIT_DIR" ]; then
  TOOLKIT_DIR=$(ls -d "$HOME/.workbuddy/plugins/cache/workbuddy-builtin/skill-expert-manager"/*/ 2>/dev/null | sort -V | tail -1)
  TOOLKIT_DIR="${TOOLKIT_DIR%/}"
fi
[ -d "${TOOLKIT_DIR:-}/scripts" ] || { echo "✗ 找不到 expert-manager 脚本目录" >&2; exit 1; }

get_version() { python3 -c "import json,sys;print(json.load(open(sys.argv[1],encoding='utf-8'))['version'])" "$PLUGIN_JSON"; }

[ -d "$SKILL_SRC" ]   || { echo "✗ 技能源不存在：$SKILL_SRC" >&2; exit 1; }
[ -f "$PLUGIN_JSON" ] || { echo "✗ plugin.json 不存在：$PLUGIN_JSON" >&2; exit 1; }

# ---------- 只比对 ----------
if [ "${1:-}" = "--check" ]; then
  echo "比对 skill/ 与安装目录："
  if diff -rq "$SKILL_SRC" "$INSTALL/skills/modern-thinking-tools" >/dev/null 2>&1; then
    echo "  ✓ 一致（v$(get_version)）"
  else
    diff -rq "$SKILL_SRC" "$INSTALL/skills/modern-thinking-tools" 2>&1 | sed 's/^/  /'
  fi
  exit 0
fi

# ---------- 版本号 ----------
if [ "${1:-}" = "--bump" ]; then
  python3 - "$PLUGIN_JSON" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding='utf-8'))
a, b, c = d['version'].split('.')
d['version'] = f"{a}.{b}.{int(c)+1}"
json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print(f"版本 {a}.{b}.{c} → {d['version']}")
PY
fi
VERSION=$(get_version)

# ---------- 组装 ----------
echo "① 组装专家包 → 安装目录"
mkdir -p "$INSTALL/skills"
rm -rf "$INSTALL/agents" "$INSTALL/.codebuddy-plugin"
cp -r "$EXPERT_SRC/." "$INSTALL/"
rm -rf "$INSTALL/skills/modern-thinking-tools"
cp -r "$SKILL_SRC" "$INSTALL/skills/modern-thinking-tools"
echo "   角色文件 + 元数据 + $(find "$SKILL_SRC" -name '*.md' | wc -l | tr -d ' ') 个技能文件"

# ---------- 校验 ----------
echo "② 校验"
( cd "$TOOLKIT_DIR" && python3 scripts/validate_expert.py "$INSTALL" )

# ---------- 注册 ----------
echo "③ 注册"
( cd "$TOOLKIT_DIR" && python3 scripts/register_expert.py "$INSTALL" ) | tail -3

# ---------- 打包 ----------
echo "④ 打包"
mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR/problem-advisor-v$VERSION.zip"
( cd "$TOOLKIT_DIR" && python3 scripts/package_expert.py "$INSTALL" "$OUT_DIR" ) >/dev/null
mv "$OUT_DIR/problem-advisor.zip" "$OUT_DIR/problem-advisor-v$VERSION.zip"

echo
echo "✅ v$VERSION 完成"
echo "   客户端已更新，可直接试"
echo "   上传包：dist/problem-advisor-v$VERSION.zip ($(du -h "$OUT_DIR/problem-advisor-v$VERSION.zip" | cut -f1))"
