#!/bin/bash
# File              : entrypoint.sh
# Author            : Alexandre Saison <alexandre.saison@inarix.com>
# Date              : 02.07.2021
# Last Modified Date: 05.07.2021
# Last Modified By  : Alexandre Saison <alexandre.saison@inarix.com>
REPO_NAME=$INPUT_REPO
SOURCE=$INPUT_HEAD
DEST=$INPUT_BASE
TITLE=$INPUT_TITLE

if [[ -z $SOURCE ]] 
then
    echo "[$(date +"%m/%d/%y %T")] An error occured during import .env variables (reason: missing head arg)"
    exit 1
elif [[ -z $REPO_NAME ]]
then
    echo "[$(date +"%m/%d/%y %T")] An error occured during import .env variables (reason: missing repo argo)"
    exit 1
elif [[ -z $DEST ]]
then
    echo "[$(date +"%m/%d/%y %T")] An error occured during import .env variables (reason: missing base arg)"
    exit 1
elif [[ -z $TITLE ]]
then
    echo "[$(date +"%m/%d/%y %T")] An error occured during import .env variables (reason: missing title arg)"
    exit 1
elif [[ -z $GITHUB_TOKEN ]]
then
    echo "[$(date +"%m/%d/%y %T")] An error occured during import .env variables (reason: missing GITHUB_TOKEN env variable)"
    exit 1
fi

echo "[$(date +"%m/%d/%y %T")] Called with repo=$REPO_NAME head=$SOURCE dest=$DEST title=$TITLE"

PULL_REQUEST=$(curl --silent --fail-with-body -L -X POST "https://api.github.com/repos/$REPO_NAME/pulls" -H "Authorization: Bearer $GITHUB_TOKEN" -H "Content-Type: application/json" --data-raw "{\"title\":\"$TITLE\", \"head\": \"$SOURCE\", \"base\": \"$DEST\"}")
PR_NUMBER=$(echo $PULL_REQUEST | jq -r .number)

echo "::group::debug"
echo "$(echo $PULL_REQUEST | jq)"
echo "::endgroup::"

if [[ -z $PR_NUMBER || $PR_NUMBER == "" ]]
then
  echo "[$(date +"%m/%d/%y %T")] An error occured during creation of PullRequest (missing number value in response)"
  exit 1
fi

echo "Created pull request number is $PR_NUMBER"
echo "::set-output name=pullNumber::$PR_NUMBER"
exit 0
