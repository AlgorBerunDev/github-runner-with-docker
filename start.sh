#!/bin/bash

ORGANIZATION=$GITHUB_ORGANIZATION
REPO=$GITHUB_REPO
ACCESS_TOKEN=$GITHUB_ACCESS_TOKEN

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="dockerized-runner-${RUNNER_SUFFIX}"

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/repos/${ORGANIZATION}/${REPO}/actions/runners/registration-token | jq .token --raw-output)

cd /home/github-runner

./config.sh --url https://github.com/${ORGANIZATION}/${REPO} --token ${REG_TOKEN} --name ${RUNNER_NAME} --labels docker --unattended --replace

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
