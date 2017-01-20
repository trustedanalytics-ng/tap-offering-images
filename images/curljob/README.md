# README #
Jupyter TAP hooks. Supply functionality creating/deleting (dedicated for particular jupyter instance) oauth client account.

## Building docker image for hook
Use the Dockerfile, provided in here, for building image that contains creating/deleting jupyter instance TAP hook logic.
Before creating jupyter instance from TAP offering, tap-containers-broker executes bin/addclient.sh bash script.
Deleting jupyter instance action is preceded by running bin/delclient.sh script.
