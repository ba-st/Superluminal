#!/usr/bin/env bash

set -e

if [[ -z "${GITHUB_HEAD_REF##*/}" ]]; then
  echo "BRANCH_NAME=${GITHUB_REF##*/}" > .env
else
  echo "BRANCH_NAME=${GITHUB_HEAD_REF##*/}" > .env
fi
docker-compose -f api-tests/docker-compose.yml up -d
echo "Waiting for API client to discover dependencies and exit"
sleep 15
EXIT_CODE=$(docker inspect api-tests_api-client_1 --format='{{.State.ExitCode}}')
echo "Exited with code: $EXIT_CODE"
docker-compose -f api-tests/docker-compose.yml down
exit $EXIT_CODE
