#!/bin/sh
curl -s -X DELETE -H "content-type: application/json;charset=utf-8" -H "Authorization: Bearer `curl -s --user ${ADMIN_CLIENT_ID}:${ADMIN_CLIENT_SECRET} -X POST -d "grant_type=client_credentials" ${UAA_ADDRESS}/oauth/token | jq -r '.access_token'`" ${UAA_ADDRESS}/oauth/clients/${OAUTH_CLIENT_ID}
