# nzbget

[![Docker Stars](https://img.shields.io/docker/stars/bbsan/ts-nzbget.svg)]()
[![Docker Pulls](https://img.shields.io/docker/pulls/bbsan/ts-nzbget.svg))]()
[![](https://images.microbadger.com/badges/image/bbsan/ts-nzbget.svg))](http://microbadger.com/images/bbsan/ts-nzbget "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/bbsan/ts-nzbget.svg))](http://microbadger.com/images/bbsan/ts-nzbget "Get your own version badge on microbadger.com")

## nzbget - The automated Usenet download tool ##

[nzbget](https://nzbget.net/) NZBGet is a binary downloader, which downloads files from Usenet based on information given in nzb-files.

It's totally free, incredibly easy to use, and works practically everywhere.
NZBGet is written in C++ and is known for its extraordinary performance and efficiency.

NZBGet can be run at almost every platform - classic PCs, NAS, media players, SAT-receivers, WLAN-routers, etc. The download area provides precompiled binaries for Windows, Mac OS X and Linux (compatible with many CPUs and platform variants). For other platforms the program can be compiled from sources.


## Updates ##

**2017-06-05 - v1.0**

 * Initial version based on technosofts alpine base-image[technosoft2000/alpine-base:3.6-2](https://hub.docker.com/r/technosoft2000/alpine-base/)
 * supports now __PGID__ < 1000

For previous changes see at [full changelog](CHANGELOG.md).

## Features ##

 * running nzbget under its own user (not root)
 * changing of the UID and GID for the nzbget user
 * support of nzbToMedia post-processing scripts from https://github.com/clinton-hall/nzbToMedia
 * support of MP4_Automator post-processing scripts from https://github.com/mdhiggins/sickbeard_mp4_automator

## Usage ##

__Create the container:__

```
docker create --name=nzbget --restart=always \
-v <your nzbget config folder>:/nzbget/config \
-v <your downloads folder>:/downloads \
[-e NZBGET_CHANNEL="stable"]
[-e NZBTOMEDIA_REPO="https://github.com/clinton-hall/nzbToMedia.git" \]
[-e NZBTOMEDIA_BRANCH="master" \]
[-e MP4_AUTOMATOR_REPO="https://github.com/mdhiggins/sickbeard_mp4_automator.git" \]
[-e MP4_AUTOMATOR_BRANCH="master" \]
[-e SET_CONTAINER_TIMEZONE=true \]
[-e CONTAINER_TIMEZONE=<container timezone value> \]
[-e PGID=<group ID (gid)> -e PUID=<user ID (uid)> \]
-p <HTTP PORT>:6789 \
ts-bbsan/nzbget
```

__Example:__

```
docker create --name=nzbget --restart=always \
-v /volume1/docker/apps/nzbget/config:/nzbget/config \
-v /volume1/downloads:/downloads \
-v /etc/localtime:/etc/localtime:ro \
-e PGID=65539 -e PUID=1029 \
-p 6789:6789 \
bbsan/ts-nzbget
```

or

```
docker create --name=nzbget --restart=always \
-v /volume1/docker/apps/nzbget/config:/nzbget/config \
-v /volume1/downloads:/downloads \
-e NZBGET_CHANNEL="testing" \
-e SET_CONTAINER_TIMEZONE=true \
-e CONTAINER_TIMEZONE=Europe/Vienna \
-e PGID=65539 -e PUID=1029 \
-p 9876:6789 \
bbsan/ts-nzbget
```

__Start the container:__
```
docker start nzbget
```

## Parameters ##

### Introduction ###
The parameters are split into two parts which are separated via colon.
The left side describes the host and the right side the container. 
For example a port definition looks like this ```-p external:internal``` and defines the port mapping from internal (the container) to external (the host).
So ```-p 8080:80``` would expose port __80__ from inside the container to be accessible from the host's IP on port __8080__.
Accessing http://'host':8080 (e.g. http://192.168.0.10:8080) would then show you what's running **INSIDE** the container on port __80__.

### Details ###
* `-p 6789` - http port for the web user interface
* `-v /nzbget/config` - local path for nzbget config files; at `/nzbget/scripts` the post processing scripts are available
* `-v /downloads/complete` - the folder where nzbget  puts the completed downloads
* `-v /downloads/incomplete` - the folder where nzbget  puts the incomplete downloads and temporary files
* `-v /downloads/nzb` - the folder where nzbget  is searching for nzb files - __optional__
* `-v /nzbget /nzbbackups` - the folder where nzbget  puts the processed nzb files for backup - __optional__
* `-v /etc/localhost` - for timesync - __optional__
* `-e APP_REPO` - set it to the nzbget  GitHub repository; by default it uses https://github.com/nzbget /nzbget .git - __optional__
* `-e APP_BRANCH` - set which nzbget d GitHub repository branch you want to use, __master__ (default branch), __0.7.x__, __1.0.x__, __1.1.x__, __develop__ - __optional__
* `-e NZBTOMEDIA_REPO` - set it to the nzbToMedia GitHub repository; by default it uses "https://github.com/clinton-hall/nzbToMedia.git" - __optional__
* `-e NZBTOMEDIA_BRANCH` - set it to the nzbToMedia GitHub repository branch you want to use, __master__ (default branch), __nightly__, __more-cleanup__, __dev__ - __optional__
* `-e PAR2_REPO` - set it to the par2commandline GitHub repoitory; by default it uses "https://github.com/Parchive/par2cmdline.git" - __optional__
* `-e PAR2_BRANCH` - set it to the par2commandline GitHub repository branch or tag you want to use, __master__, __v0.6.14__, __v0.7.1__ (default tag) - __optional__
* `-e SET_CONTAINER_TIMEZONE` - set it to `true` if the specified `CONTAINER_TIMEZONE` should be used - __optional__
* `-e CONTAINER_TIMEZONE` - container timezone as found under the directory `/usr/share/zoneinfo/` - __optional__
* `-e PGID` for GroupID - see below for explanation - __optional__
* `-e PUID` for UserID - see below for explanation - __optional__

### Container Timezone

In the case of the Synology NAS it is not possible to map `/etc/localtime` for timesync, and for this and similar case
set `SET_CONTAINER_TIMEZONE` to `true` and specify with `CONTAINER_TIMEZONE` which timezone should be used.
The possible container timezones can be found under the directory `/usr/share/zoneinfo/`.

Examples:

 * ```UTC``` - __this is the default value if no value is set__
 * ```Europe/Berlin```
 * ```Europe/Vienna```
 * ```America/New_York```
 * ...

__Don't use the value__ `localtime` because it results into: `failed to access '/etc/localtime': Too many levels of symbolic links`

## User / Group Identifiers ##
Sometimes when using data volumes (-v flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user PUID and group PGID. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance PUID=1001 and PGID=1001. To find yours use id user as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Additional ##
Shell access whilst the container is running: `docker exec -it nzbget  /bin/bash`

Upgrade to the latest version of nzbget : `docker restart nzbget `

To monitor the logs of the container in realtime: `docker logs -f nzbget `

To edit the MP4_Automator autoprocess.ini: `docker exec -it nzbget /usr/bin/vi /nzbget/scripts/MP4_Automator/autoProcess.ini`

---

## For Synology NAS users ##

Login into the DSM Web Management
* Open the Control Panel
* Control _Panel_ > _Privilege_ > _Group_ and create a new one with the name 'docker'
* add the permissions for the directories 'downloads', 'video' and so on
* disallow the permissons to use the applications
* Control _Panel_ > _Privilege_ > _User_ and create a new on with name 'docker' and assign this user to the group 'docker'

Connect with SSH to your NAS
* after sucessful connection change to the root account via
```
sudo -i
```
or
```
sudo su -
```
for the password use the same one which was used for the SSH authentication.

* create a 'docker' directory on your volume (if such doesn't exist)
```
mkdir -p /volume1/docker/
chown root:root /volume1/docker/
```

* create a 'nzbget ' directory
```
cd /volume1/docker
mkdir apps
chown docker:docker apps
cd apps
mkdir -p nzbget /config
chown -R docker:docker nzbget 
```

* get your Docker User ID and Group ID of your previously created user and group
```
id docker
uid=1029(docker) gid=100(users) groups=100(users),65539(docker)
```

* get the Docker image
```
docker pull bbsan/ts-nzbget 
```

* create a Docker container (take care regarding the user ID and group ID, change timezone and port as needed)
```
docker create --name=nzbget  --restart=always \
-v /volume1/docker/apps/nzbget/config:/nzbget/config \
-v /volume1/downloads:/downloads \
-e NZBGET_CHANNEL="stable" \
-e SET_CONTAINER_TIMEZONE=true \
-e CONTAINER_TIMEZONE=Europe/Vienna \
-e PGID=65539 -e PUID=1029 \
-p 6789:6789 \
bbsan/ts-nzbget 
```

* check if the Docker container was created successfully
```
docker ps -a
CONTAINER ID        IMAGE                           COMMAND                CREATED             STATUS              PORTS               NAMES
b95e7f3da141        bbsan/ts-nzbget          "/bin/bash -c /init/s" 8 seconds ago       Created 
```

* start the Docker container
```
docker start nzbget
```

* analyze the log (stop it with CTRL+C)
```
docker logs -f nzbget
[INFO] Docker image version: 1.0
[INFO] Alpine Linux version: 3.6.0
[WARNING] A group with id 100 exists already [in use by users] and will be modified.
[WARNING] The group users will be renamed to nzbget
[INFO] Create user nzbget with id 1004
[INFO] Current active timezone is CEST
[INFO] Change the ownership of /nzbget (including subfolders) to nzbget:nzbget
[INFO] Installed version is 18.1
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   611  100   611    0     0  13596      0 --:--:-- --:--:-- --:--:-- 20366
[INFO] Latest version is 18.1
[INFO] Current git version is:
git version 2.13.0
[INFO] Checkout the latest nzbToMedia version ...
[INFO] ... git clone -b master --single-branch https://github.com/clinton-hall/nzbToMedia.git /nzbget/scripts/nzbToMedia -v
Cloning into '/nzbget/scripts/nzbToMedia'...
POST git-upload-pack (189 bytes)
[INFO] Autoupdate is active, try to pull the latest sources for nzbToMedia ...
[INFO] ... current git status is
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
80c8ad58523ab99825c02f3855f9bd3dc9945d57
[INFO] ... pulling sources
Already up-to-date.
[INFO] ... git status after update is
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
80c8ad58523ab99825c02f3855f9bd3dc9945d57
[INFO] Current git version is:
git version 2.13.0
[INFO] Checkout the latest mp4_automator version ...
[INFO] ... git clone -b master --single-branch https://github.com/mdhiggins/sickbeard_mp4_automator.git /nzbget/scripts/MP4_Automator -v
Cloning into '/nzbget/scripts/MP4_Automator'...
POST git-upload-pack (189 bytes)
[INFO] Autoupdate is active, try to pull the latest sources for mp4_automator ...
[INFO] ... current git status is
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
e205c1f5b03072efd6bc51c71cc0286229820e89
[INFO] ... pulling sources
Already up-to-date.
[INFO] ... git status after update is
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
e205c1f5b03072efd6bc51c71cc0286229820e89
[INFO] Launching nzbget ...
[INFO] nzbget 18.1 server-mode
[WARNING] Request received on port 6789 from 192.168.177.30, but username or password invalid (nzbget:Brandybock)
[INFO] Reloading...
[INFO] nzbget 18.1 server-mode
[INFO] Docker image version: 1.0
[INFO] Alpine Linux version: 3.6.0
[WARNING] A group with id 100 exists already [in use by nzbget] and will be modified.
[WARNING] The group nzbget will be renamed to nzbget
[WARNING] A user with id 1004 exists already [in use by nzbget] and will be modified.
[WARNING] The user nzbget will renamed to nzbget and assigned to group nzbget
usermod: no changes
[INFO] Current active timezone is CEST
[INFO] Change the ownership of /nzbget (including subfolders) to nzbget:nzbget
[INFO] Installed version is 18.1
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   611  100   611    0     0  13331      0 --:--:-- --:--:-- --:--:-- 21068
[INFO] Latest version is 18.1
[INFO] Current git version is:
git version 2.13.0
[INFO] Checkout the latest nzbToMedia version ...
[INFO] Autoupdate is active, try to pull the latest sources for nzbToMedia ...
[INFO] ... current git status is
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
80c8ad58523ab99825c02f3855f9bd3dc9945d57
[INFO] ... pulling sources
Already up-to-date.
[INFO] ... git status after update is
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
80c8ad58523ab99825c02f3855f9bd3dc9945d57
[INFO] Current git version is:
git version 2.13.0
[INFO] Checkout the latest mp4_automator version ...
[INFO] Autoupdate is active, try to pull the latest sources for mp4_automator ...
[INFO] ... current git status is
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
e205c1f5b03072efd6bc51c71cc0286229820e89
[INFO] ... pulling sources
Already up-to-date.
[INFO] ... git status after update is
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
e205c1f5b03072efd6bc51c71cc0286229820e89
[INFO] Launching nzbget ...
[INFO] nzbget 18.1 server-mode
[INFO] Reloading...
[INFO] nzbget 18.1 server-mode
