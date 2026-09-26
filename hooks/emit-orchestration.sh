#!/bin/sh
# Emits the psyflow orchestration policy at SessionStart.
# Derived from pilotfish v1.4.1 emit-sessionstart.sh
# (https://github.com/Nanako0129/pilotfish), MIT License © 2026 Nanako0129.
set -eu
PATH=/usr/bin:/bin
export PATH

# A non-empty CLAUDE_CODE_SUBAGENT_MODEL overrides every agent model
# frontmatter, silently breaking the cost routing this policy depends on.
if [ -n "${CLAUDE_CODE_SUBAGENT_MODEL:-}" ]; then
    printf '%s\n' "psyflow orchestration blocked: CLAUDE_CODE_SUBAGENT_MODEL is non-empty and overrides every agent model frontmatter. Unset it, then restart Claude Code."
    exit 0
fi

# Fail closed if a legacy global pilotfish install is still present —
# two orchestration policies at once contradict each other.
if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
    case "$CLAUDE_CONFIG_DIR" in
        /*) config_root=$CLAUDE_CONFIG_DIR ;;
        *) printf '%s\n' "psyflow orchestration blocked: CLAUDE_CONFIG_DIR must be absolute."; exit 0 ;;
    esac
else
    case "${HOME:-}" in
        /*) config_root=$HOME/.claude ;;
        *) printf '%s\n' "psyflow orchestration blocked: HOME must be absolute when CLAUDE_CONFIG_DIR is empty."; exit 0 ;;
    esac
fi

config_file=$config_root/CLAUDE.md
if [ -f "$config_file" ] && [ -r "$config_file" ]; then
    set +e
    grep -F -q \
        -e '<!-- pilotfish:begin -->' \
        -e '<!-- pilotfish:end -->' \
        -e '<!-- pilotfish v' \
        "$config_file"
    grep_status=$?
    set -e
    if [ "$grep_status" -eq 0 ]; then
        printf '%s\n' "psyflow orchestration blocked: a legacy global pilotfish block was found in CLAUDE.md. Remove it (or uninstall legacy pilotfish), then restart Claude Code."
        exit 0
    fi
fi

# Strip the leading provenance comment — attribution lives in the file and
# the repo; no need to spend those tokens in every session.
awk 'BEGIN{skip=0} NR==1 && /^<!--/{skip=1} skip{if(/-->/){skip=0}; next} {print}' \
    "${CLAUDE_PLUGIN_ROOT}/policy/orchestration.md"
