#!/bin/bash

source ./.env

export GITHUB_TOKEN
export TG_TOKEN
export TG_CHAT_ID
export JENKINS_PASSWORD

envsubst < jenkins/jenkins-secret-template.yaml > jenkins/jenkins-secret.yaml

JCASC_GITHUB_TOKEN=$(echo "${GITHUB_TOKEN}" | base64 -d)
JCASC_TG_TOKEN=$(echo "${TG_TOKEN}" | base64 -d)
JCASC_TG_CHAT_ID=$(echo "${TG_CHAT_ID}" | base64 -d)
JCASC_JENKINS_PASSWORD=$(echo "${JENKINS_PASSWORD}" | base64 -d)

echo $JCASC_GITHUB_TOKEN
echo $JCASC_TG_TOKEN
echo $JCASC_TG_CHAT_ID
echo $JCASC_JENKINS_PASSWORD