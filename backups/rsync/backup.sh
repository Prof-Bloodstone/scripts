#!/usr/bin/env bash
set -euo pipefail

BACKUP_DEST='/path/do/snapshots'
BACKUP_SRC="${HOME}/"

rsync_opts=(
  --acls
  --archive
  --delete # Delete old files I already did delete
  --hard-links
  --open-noatime
  --partial
  --progress
  --times
  --xattrs
  --quiet
)

excludes=(
  # Values starting with / are from the source dir
  "/.cache/"
  "/.cargo/"
  "/.config/JetBrains/"
  "/.gradle/"
  "/.local/lib/MATLAB/"
  "/.m2/"
  "/.rustup/"
  "/.tmp/"
  "/.wine/"
  "/Downloads/"
  "/Games/"
  "/VirtualBox VMs/"
  "/go/"
  "build/" # Gradle compile directory
  "lost+found"
  "target/" # RUST compile directory
)

# run this process with real low priority
ionice -c 3 -p $$
renice +12  -p $$

print() {
  printf '%s\n' "${*}"
}

[ -d "${BACKUP_DEST}" ] || {
  print "Destination directory not found at ${BACKUP_DEST@Q}"
  print "Did you mount the drive?"
  exit 1
}

excludes_args=()
for exclude in "${excludes[@]}"; do
  excludes_args+=( --exclude="${exclude}" )
done

timestamp="$(date --iso-8601=s)"
latest_backup="${BACKUP_DEST}/latest"
current_backup="${BACKUP_DEST}/${timestamp}"

full_args=(
  rsync
  "${rsync_opts[@]}"
  "${excludes_args[@]}"
  "${BACKUP_SRC}"
  "${current_backup}"
)

if [ -e "${latest_backup}" ]; then
  if [ -L "${latest_backup}" ]; then
    print "Existing backups found - will use hardlinks"
    full_args+=( --link-dest="${latest_backup}" )
  else
    print "ERROR: ${latest_backup} exists and is not a symlink!"
    exit 1
  fi
else
  print "First time backup detected!"
fi

full_args+=( "${@}" )

print "Running: ${full_args[*]@Q}"

"${full_args[@]}" || {
  exit_code="$?"
  print "ERROR(${exit_code}) while taking backup - see logs above."
  print "The target directory: ${current_backup}"
  print "Latest backup symlink not updated."
  exit "${exit_code}"
}

ln --symbolic --relative --force --no-target-directory "${current_backup}" "${latest_backup}"
