#!/bin/sh
ACCESS_TOKEN=`curl -s --user ${ADMIN_CLIENT_ID}:${ADMIN_CLIENT_SECRET} -X POST -d "grant_type=client_credentials" ${UAA_ADDRESS}/oauth/token | jq -r '.access_token'`
curl -s -X POST -H "content-type: application/json;charset=utf-8" -H "Authorization: Bearer ${ACCESS_TOKEN}" -d '{"client_id":"'${OAUTH_CLIENT_ID}'","client_secret":"'${OAUTH_CLIENT_SECRET}'","name":"'${OAUTH_CLIENT_ID}'","scope":["openid","cloud_controller.read","tap.user"],"authorized_grant_types":["authorization_code"],"redirect_uri":["'${REDIRECT_URI}'"],"autoapprove":"true"}' ${UAA_ADDRESS}/oauth/clients > /dev/null
USER_DATA=`curl -s -X GET -H "content-type: application/json;charset=utf-8" -H "Authorization: Bearer ${ACCESS_TOKEN}"  ${UAA_ADDRESS}/Users?filter=userName+eq+%22$USER_NAME%22&startIndex=1`
USER_ID=`echo $USER_DATA | jq .resources[0].id | tr -d '"'`
echo {\"HADOOP_USER_NAME\":\"$USER_ID\"}
