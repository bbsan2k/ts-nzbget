#!/bin/bash

# launch the APP
echo "[INFO] Launching $APP_NAME ..."
gosu $PUSER:$PGROUP /nzbget/app/nzbget -s -c /nzbget/config/nzbget.conf \
	-o OutputMode=log