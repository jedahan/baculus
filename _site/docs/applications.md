## Baculus Build Log

### Application Setup

* get cjdns public address
* start scuttlebot
  * --host=$cjdns --allowPrivate
* create an invite with scuttlebot
* accept invite code
  * ssh <remote_address> "cd ~/scuttlebot && node bin invite.accept $invite_code"`
* open up patchfoo

### Todo

Add `ssb_appname=bac` to env

Getting the sector antennae as an access point

installing base image on all three pis

filling out cjdns addresses



