#!/usr/bin/env bash
# vim: sw=2

set -euo pipefail

: "${python_exec:=./venv/bin/python}"
: "${python_script:=./notify.py}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${DIR}"

{
  echo '##### Loading env vars #####'
  source .envrc
  echo '##### Starting notification script #####'
  "${python_exec}" -u "${python_script}" 
  echo '##### Ending notification script #####'
} 2>&1 | awk '/^[[:space:]]*$/ {print $0; next;} { "date" | getline d; printf("[%s] %s\n", d, $0); close("date")}' | tee -a cron.log
