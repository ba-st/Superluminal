#!/usr/bin/env bash

set -e

if [[ -z "${GITHUB_HEAD_REF##*/}" ]]; then
  echo "BRANCH_NAME=${GITHUB_REF##*/}" > .env
else
  echo "BRANCH_NAME=${GITHUB_HEAD_REF##*/}" > .env
fi
set +e # disable exit on error to be able to catch the exit code from compose
docker-compose -f api-tests/docker-compose.yml up --exit-code-from api-client
