#!/usr/bin/env bash

set -e

if [[ -z "${GITHUB_HEAD_REF##*/}" ]]; then
  echo "BRANCH_NAME=${GITHUB_REF##*/}" > api-tests/.env
else
  echo "BRANCH_NAME=${GITHUB_HEAD_REF##*/}" > api-tests/.env
fi
set +e # disable exit on error to be able to catch the exit code from compose
docker compose \
  --file api-tests/docker-compose.yml \
  up \
  --build api-client \
  --exit-code-from api-client
