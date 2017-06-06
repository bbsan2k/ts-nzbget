#!/bin/bash

# get or update all parts for the APP

# download the latest version of the SABnzbd
NZBGET_VERSION=$(grep "${NZBGET_CHANNEL}-version" /nzbget/versions.json  | cut -d '"' -f 4)
echo "[INFO] Installed version is $NZBGET_VERSION"

curl -o /nzbget/versions.json -L http://nzbget.net/info/nzbget-version-linux.json
NZBGET_LATEST_VERSION=$(grep "${NZBGET_CHANNEL}-version" /nzbget/versions.json  | cut -d '"' -f 4)
echo "[INFO] Latest version is $NZBGET_LATEST_VERSION"

if [ "$NZBGET_VERSION" != "$NZBGET_LATEST_VERSION" ]; then
	echo "[INFO] Updating nzbget to $NZBGET_LATEST_VERSION"
	mkdir /tmp
	NZBGET_LATEST_URL=$(grep "${NZBGET_CHANNEL}-download" /nzbget/versions.json  | cut -d '"' -f 4)
	curl -o \
	/tmp/nzbget.run -L "${NZBGET_LATEST_URL}"
	
    sh /tmp/nzbget.run --destdir /nzbget/app
    rm -rf /tmp
fi

# remove nzbget lock files
[[ -f /downloads/nzbget.lock ]] && \
	rm /downloads/nzbget.lock

# check if config exists in /defaults, copy and configure if not
if [ ! -e /defaults/nzbget.conf ]; then
	mkdir /defaults
	cp /nzbget/app/nzbget.conf /defaults/nzbget.conf
	sed -i \
		-e "s#\(MainDir=\).*#\1/downloads#g" \
		-e "s#\(ScriptDir=\).*#\1$\{MainDir\}/scripts#g" \
		-e "s#\(WebDir=\).*#\1$\{AppDir\}/webui#g" \
		-e "s#\(ConfigTemplate=\).*#\1$\{AppDir\}/webui/nzbget.conf.template#g" \
	/defaults/nzbget.conf
fi


# download the latest version of the nzbToMedia
# see at https://github.com/clinton-hall/nzbToMedia.git
source /init/checkout.sh "nzbToMedia" "$NZBTOMEDIA_BRANCH" "$NZBTOMEDIA_REPO" "/scripts/nzbToMedia"


#append nzbToMedia to ScriptDir if not done already
if ! grep -q "/scripts/nzbToMedia" /defaults/nzbget.conf; then
	sed -i \
		-e 	'\|^ScriptDir|s|$|;/scripts/nzbToMedia|' \
		/defaults/nzbget.conf
fi

source /init/checkout.sh "mp4_automator" "$MP4_AUTOMATOR_BRANCH" "$MP4_AUTOMATOR_REPO" "/scripts/MP4_Automator"

#append mp4_automator to ScriptDir if not done already
if ! grep -q "/scripts/MP4_Automator" /defaults/nzbget.conf; then
	sed -i \
		-e 	'\|^ScriptDir|s|$|;/scripts/MP4_Automator|' \
		/defaults/nzbget.conf
fi

# check if config exists in /config, copy if not
if [[ ! -e /nzbget/config/nzbget.conf ]]; then
	cp /defaults/nzbget.conf /nzbget/config/nzbget.conf
fi
