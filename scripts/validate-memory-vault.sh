#!/usr/bin/env bash
set -euo pipefail

VAULT="${1:-/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultMemory}"

required=(
  "README.md"
  "evidence/daily"
  "evidence/sessions"
  "outcomes"
  "execution/open-loops.md"
  "reusable"
  "views/active-now.md"
  "views/career-impact.md"
  "governance/ontology/contract.md"
  "governance/approvals"
  "governance/maintenance"
  "governance/preferences/approval-routing.md"
)

for path in "${required[@]}"; do
  if [ ! -e "${VAULT}/${path}" ]; then
    echo "Missing: ${VAULT}/${path}" >&2
    exit 1
  fi
done

for old_path in \
  "MEMORY.md" \
  "DREAMS.md" \
  "dreams.md" \
  "governance/dreams.md" \
  "memory" \
  "memory/active" \
  "memory/approvals" \
  "memory/career" \
  "memory/commitments" \
  "memory/daily" \
  "memory/decisions" \
  "memory/maintenance" \
  "memory/ontology" \
  "memory/patterns" \
  "memory/people" \
  "memory/preferences" \
  "memory/projects" \
  "memory/toolkits"; do
  if [ -e "${VAULT}/${old_path}" ]; then
    echo "Obsolete path still exists: ${VAULT}/${old_path}" >&2
    exit 1
  fi
done

echo "Vault structure looks valid: ${VAULT}"

python3 - "${VAULT}" <<'PYEOF'
import os, re, sys
vault = sys.argv[1]
ALLOWED = {
    "evidence": {"daily", "session"},
    "outcome": {"delivery", "pursuit", "initiative"},
    "execution": {"open-loops"},
    "reusable": {"pattern", "framework", "career"},
    "view": {"attention", "career-impact"},
    "governance": {"ontology-contract", "approval-queue", "approval-routing", "maintenance-report"},
}
errors = []
def fm_value(fm, key):
    m = re.search(rf"^{key}:[ \t]*(.+)$", fm, re.M)
    return m.group(1).strip().strip('"\'') if m else None
for root, dirs, files in os.walk(vault):
    if os.sep + ".obsidian" in root:
        continue
    for fn in files:
        if not fn.endswith(".md"):
            continue
        full = os.path.join(root, fn)
        rel = os.path.relpath(full, vault).replace(os.sep, "/")
        if rel == "README.md":
            continue
        with open(full, encoding="utf-8") as f:
            text = f.read()
        m = re.match(r"^---\n(.*?\n)---", text, re.S)
        if not m:
            errors.append(f"{rel}: no frontmatter")
            continue
        fm = m.group(1)
        t = fm_value(fm, "type")
        s = fm_value(fm, "subtype")
        if t not in ALLOWED:
            errors.append(f"{rel}: type '{t}' not in the six flat values {sorted(ALLOWED)}")
            continue
        folder = rel.split("/", 1)[0]
        folder_map = {"evidence":"evidence","outcomes":"outcome","execution":"execution",
                      "reusable":"reusable","views":"view","governance":"governance"}
        expected = folder_map.get(folder)
        if expected and t != expected:
            errors.append(f"{rel}: type '{t}' does not match folder '{folder}' (expected '{expected}')")
        if s is not None and s not in ALLOWED.get(t, set()):
            errors.append(f"{rel}: subtype '{s}' not allowed for type '{t}' ({sorted(ALLOWED.get(t, set()))})")
if errors:
    print("Frontmatter schema lint FAILED:", file=sys.stderr)
    for e in errors:
        print("  - " + e, file=sys.stderr)
    sys.exit(1)
print("Frontmatter schema lint passed: type/subtype within controlled vocabulary")
PYEOF
