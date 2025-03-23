#!/bin/bash

set -eo pipefail

JENKINS_URL='http://localhost:8080'
JENKINS_USER='admin'
JENKINS_PASSWORD='admin@1234'

# Get Jenkins crumb
JENKINS_CRUMB=$(curl -s --cookie-jar /tmp/cookies -u $JENKINS_USER:$JENKINS_PASSWORD ${JENKINS_URL}/crumbIssuer/api/json | jq .crumb -r)

# Generate Jenkins API token
JENKINS_TOKEN=$(curl -s -X POST -H "Jenkins-Crumb:${JENKINS_CRUMB}" --cookie /tmp/cookies "${JENKINS_URL}/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=demo-token66" -u $JENKINS_USER:$JENKINS_PASSWORD | jq .data.tokenValue -r)

echo "Jenkins URL: $JENKINS_URL"
echo "Jenkins Crumb: $JENKINS_CRUMB"
echo "Jenkins Token: $JENKINS_TOKEN"

# Install plugins listed in plugins.txt
while read -r plugin; do
   echo "........Installing ${plugin} .."
   curl -s -X POST --data "<jenkins><install plugin='${plugin}' /></jenkins>" -H 'Content-Type: text/xml' "$JENKINS_URL/pluginManager/installNecessaryPlugins" --user "$JENKINS_USER:$JENKINS_TOKEN"
done < plugins.txt

# Optionally restart Jenkins to apply changes
# curl -X POST "$JENKINS_URL/safeRestart" --user "$JENKINS_USER:$JENKINS_TOKEN"

# Check all installed plugins
# curl -s "$JENKINS_URL/scriptText" --data-urlencode "script=$(< check_plugins.groovy)" --user "$JENKINS_USER:$JENKINS_TOKEN"

# check_plugins.groovy content:
# Jenkins.instance.pluginManager.plugins.each{
#   plugin -> 
#     println ("${plugin.getDisplayName()} (${plugin.getShortName()}): ${plugin.getVersion()}")
# }

# Check for updates/errors
# curl -s "$JENKINS_URL/updateCenter" --user "$JENKINS_USER:$JENKINS_TOKEN"