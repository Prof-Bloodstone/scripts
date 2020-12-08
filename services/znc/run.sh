#!/usr/bin/env bash

data_dir="znc-data"

[ -d "${data_dir}" ] || {
  echo Preparing znc...
  mkdir "${data_dir}"
  docker-compose run znc --makeconf
}

echo Starting znc...
docker-compose up -d
