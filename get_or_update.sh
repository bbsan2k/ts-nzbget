#!/bin/bash

# get or update all parts for the APP

# download the latest version of the SABnzbd
NZBGET_VERSION=$(grep "${NZBGET_BRANCH}" /nzbget/versions.json  | cut -d '"' -f 4)
echo "[INFO] Installed version is $NZBGET_VERSION"

curl -o /tmp/versions.json -L http://nzbget.net/info/nzbget-version-linux.json
NZBGET_LATEST_VERSION=$(grep "${NZBGET_BRANCH}" /tmp/versions.json  | cut -d '"' -f 4)
echo "[INFO] Latest version is $NZBGET_LATEST_VERSION"

if [ "$NZBGET_VERSION" != "$NZBGET_LATEST_VERSION" ]; then
	echo "[INFO] Updating nzbget to $NZBGET_LATEST_VERSION"
	curl -o \
	/tmp/nzbget.run -L "${NZBGET_LATEST_VERSION}"
    sh /tmp/nzbget.run --destdir /nzbget/app
    mv /tmp/versions.json /nzbget/


# remove nzbget lock files
[[ -f /downloads/nzbget.lock ]] && \
	rm /downloads/nzbget.lock

# check if config exists in /defaults, copy and configure if not
if [ ! -e /defaults/nzbget.conf ]; then
cp /nzbget/app/nzbget.conf /defaults/nzbget.conf
sed -i \
	-e "s#\(MainDir=\).*#\1/downloads#g" \
	-e "s#\(ScriptDir=\).*#\1$\{MainDir\}/scripts#g" \
	-e "s#\(WebDir=\).*#\1$\{AppDir\}/webui#g" \
	-e "s#\(ConfigTemplate=\).*#\1$\{AppDir\}/webui/nzbget.conf.template#g" \
/defaults/nzbget.conf
fi

# check if config exists in /config, copy if not
[[ ! -e /nzbget/config/nzbget.conf ]] && \
	cp /defaults/nzbget.conf /nzbget/config/nzbget.conf



# download the latest version of the nzbToMedia
# see at https://github.com/clinton-hall/nzbToMedia.git
source /init/checkout.sh "nzbToMedia" "$NZBTOMEDIA_BRANCH" "$NZBTOMEDIA_REPO" "$APP_HOME/config/scripts"

