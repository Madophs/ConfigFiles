#!/bin/bash

TOKEN=$(${MDS_SCRIPTS}/handle_git_token.sh show)

${MDS_SCRIPTS}/git_fetch_expect.sh ${TOKEN}
