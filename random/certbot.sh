#!/usr/bin/env bash

set -euo pipefail

email=user@example.com
cert_dir="${HOME}/certbot/certs/"
letsencrypt_dir="${HOME}/certbot/letsencrypt/"
logs_dir="${HOME}/certbot/logs/"

docker_args=(
  --rm
  --name cerbot
  --volume "${cert_dir}:/etc/letsencrypt"
  --volume "${letsencrypt_dir}:/var/lib/letsencrypt"
  --volume "${logs_dir}:/var/log/letsencrypt"
  -p 80:80
  -p 443:443
  certbot/certbot
)

certbot_args=(
  certonly
  --non-interactive
  --agree-tos
  --keep-until-expiring
  --standalone
  --email "${email}"
  -d "my.example.com"
  --post-hook "chown -R $(id -u):$(id -g) /etc/letsencrypt /var/lib/letsencrypt /var/log/letsencrypt"
  --dry-run # Staging env
)


mkdir -p "${cert_dir}" "${letsencrypt_dir}" "${logs_dir}"

docker run "${docker_args[@]}" "${certbot_args[@]}"
