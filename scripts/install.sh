#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COPILOT_DIR="${HOME}/.copilot"
PERSOMEMORY_DATA_HOME="${PERSOMEMORY_DATA_HOME:-${HOME}/.local/share/persomemory}"
SMART_CONNECTIONS_MCP_DIR="${SMART_CONNECTIONS_MCP_DIR:-${HOME}/smart-connections-mcp}"
SMART_CONNECTIONS_MCP_REPO="${SMART_CONNECTIONS_MCP_REPO:-https://github.com/msdanyg/smart-connections-mcp.git}"
LIFECYCLE_MCP_DIR="${LIFECYCLE_MCP_DIR:-${HOME}/persomemory-lifecycle-mcp}"

copy_file_if_missing() {
  local source_file="$1"
  local target_dir="$2"
  local target_file="${target_dir}/$(basename "${source_file}")"

  if [ ! -e "${target_file}" ]; then
    cp "${source_file}" "${target_file}"
  fi
}

append_jsonl_once() {
  local source_file="$1"
  local target_file="$2"
  local tmp_file

  tmp_file="$(mktemp)"
  if [ -f "${target_file}" ]; then
    cat "${target_file}" > "${tmp_file}"
  fi
  cat "${source_file}" >> "${tmp_file}"
  awk 'NF && !seen[$0]++' "${tmp_file}" > "${target_file}"
  rm -f "${tmp_file}"
}

install_copilot_instructions() {
  local source_file="${REPO_DIR}/config/copilot-instructions.md"
  local target_file="${COPILOT_DIR}/copilot-instructions.md"
  local backup_file

  mkdir -p "${COPILOT_DIR}"

  if [ -f "${target_file}" ] && ! cmp -s "${source_file}" "${target_file}"; then
    backup_file="${target_file}.bak.$(date +%Y%m%d%H%M%S).$$"
    cp "${target_file}" "${backup_file}"
    echo "Backed up existing Copilot instructions to ${backup_file}"
  fi

  cp "${source_file}" "${target_file}"
  echo "Installed Copilot instructions to ${target_file}"
}

install_mcp_config() {
  local source_file="${REPO_DIR}/config/mcp-config.example.json"
  local target_file="${COPILOT_DIR}/mcp-config.json"

  mkdir -p "${COPILOT_DIR}"

  if [ ! -f "${target_file}" ]; then
    cp "${source_file}" "${target_file}"
    echo "Installed MCP config to ${target_file}"
    return
  fi

  if cmp -s "${source_file}" "${target_file}"; then
    echo "MCP config already matches ${source_file}"
    return
  fi

  echo "Kept existing MCP config at ${target_file}; review ${source_file} for PersoMemory entries."
}

install_skills() {
  local source_root="${REPO_DIR}/skills"
  local target_root="${COPILOT_DIR}/skills"
  local managed_dir
  local skill_dir
  local skill_name

  mkdir -p "${target_root}"

  while IFS= read -r -d '' managed_dir; do
    rm -rf "${managed_dir}"
  done < <(find "${target_root}" -mindepth 1 -maxdepth 1 -type d \( \
    -name 'persomemory' -o \
    -name 'persomemory-*' -o \
    -name 'memory' -o \
    -name 'memory-router' -o \
    -name 'memory-brief' -o \
    -name 'memory-sweep' -o \
    -name 'memory-maintenance' \
  \) -print0)

  while IFS= read -r -d '' skill_dir; do
    skill_name="$(basename "${skill_dir}")"
    mkdir -p "${target_root}/${skill_name}"
    cp -r "${skill_dir}/." "${target_root}/${skill_name}/"
    echo "Installed ${skill_name} skill to ${target_root}/${skill_name}/SKILL.md"
  done < <(find "${source_root}" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
}

install_agents() {
  local source_root="${REPO_DIR}/config/agents"
  local target_root="${COPILOT_DIR}/agents"
  local agent_file

  mkdir -p "${target_root}"
  rm -f "${target_root}/persomemory-agent.agent.md" "${target_root}/persomemory-graph-steward.agent.md"

  while IFS= read -r -d '' agent_file; do
    cp "${agent_file}" "${target_root}/$(basename "${agent_file}")"
    echo "Installed $(basename "${agent_file}" .agent.md) agent to ${target_root}/$(basename "${agent_file}")"
  done < <(find "${source_root}" -maxdepth 1 -type f -name '*.agent.md' -print0 | sort -z)
}

install_lifecycle_mcp() {
  mkdir -p "${LIFECYCLE_MCP_DIR}"
  cp -r "${REPO_DIR}/mcp/lifecycle/." "${LIFECYCLE_MCP_DIR}/"
  (cd "${LIFECYCLE_MCP_DIR}" && npm install --silent)
  echo "Installed persomemory-lifecycle MCP to ${LIFECYCLE_MCP_DIR}"
}

install_smart_connections_mcp() {
  if [ ! -d "${SMART_CONNECTIONS_MCP_DIR}" ]; then
    git clone "${SMART_CONNECTIONS_MCP_REPO}" "${SMART_CONNECTIONS_MCP_DIR}"
  fi

  if [ ! -f "${SMART_CONNECTIONS_MCP_DIR}/package.json" ]; then
    echo "Smart Connections MCP directory exists but has no package.json: ${SMART_CONNECTIONS_MCP_DIR}" >&2
    return 1
  fi

  (cd "${SMART_CONNECTIONS_MCP_DIR}" && npm install --silent && npm run build --silent)
  echo "Installed smart-connections MCP to ${SMART_CONNECTIONS_MCP_DIR}"
  echo "Open the Obsidian vault with the Smart Connections plugin enabled so it creates .smart-env/ before expecting semantic results."
}

migrate_persomemory_queue() {
  local old_dir="${COPILOT_DIR}/plugin-data/persomemory"
  local new_dir="${PERSOMEMORY_DATA_HOME}"

  if [ ! -d "${old_dir}" ]; then
    return
  fi

  mkdir -p "${new_dir}/session-reviews" "${new_dir}/session-transcripts"

  if [ -d "${old_dir}/pending-session-reviews" ]; then
    while IFS= read -r -d '' file; do
      copy_file_if_missing "${file}" "${new_dir}/session-reviews"
    done < <(find "${old_dir}/pending-session-reviews" -maxdepth 1 -type f -print0)
  fi

  if [ -d "${old_dir}/session-reviews" ]; then
    while IFS= read -r -d '' file; do
      copy_file_if_missing "${file}" "${new_dir}/session-reviews"
    done < <(find "${old_dir}/session-reviews" -maxdepth 1 -type f -print0)
  fi

  if [ -d "${old_dir}/session-transcripts" ]; then
    while IFS= read -r -d '' file; do
      copy_file_if_missing "${file}" "${new_dir}/session-transcripts"
    done < <(find "${old_dir}/session-transcripts" -maxdepth 1 -type f -print0)
  fi

  if [ -f "${old_dir}/session-end-events.jsonl" ]; then
    append_jsonl_once "${old_dir}/session-end-events.jsonl" "${new_dir}/session-end-events.jsonl"
  fi

  find "${old_dir}" -type d -empty -delete 2>/dev/null || true
  echo "Migrated PersoMemory queue data to ${new_dir}"
}

main() {
  install_copilot_instructions
  install_mcp_config

  install_skills

  mkdir -p "${HOME}/.local/bin"
  cp "${REPO_DIR}/scripts/run-evening-sweep.sh" "${HOME}/.local/bin/persomemory-evening-sweep"
  chmod +x "${HOME}/.local/bin/persomemory-evening-sweep"
  echo "Installed PersoMemory evening sweep helper to ${HOME}/.local/bin/persomemory-evening-sweep"

  install_agents

  mkdir -p "${COPILOT_DIR}/hooks/scripts"
  cp "${REPO_DIR}/config/hooks/persomemory-session.json" "${COPILOT_DIR}/hooks/persomemory-session.json"
  cp "${REPO_DIR}/config/hooks/scripts/persomemory-session-start.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-session-start.sh"
  cp "${REPO_DIR}/config/hooks/scripts/persomemory-agent-stop.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-agent-stop.sh"
  cp "${REPO_DIR}/config/hooks/scripts/persomemory-session-end.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-session-end.sh"
  chmod +x "${COPILOT_DIR}/hooks/scripts/persomemory-session-start.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-agent-stop.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-session-end.sh"
  echo "Installed PersoMemory hooks to ${COPILOT_DIR}/hooks/persomemory-session.json"
  migrate_persomemory_queue

  install_lifecycle_mcp
  install_smart_connections_mcp

  echo "Review ${COPILOT_DIR}/mcp-config.json before starting Copilot CLI."
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
