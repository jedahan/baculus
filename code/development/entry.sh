# This script is for developing scuttlebutt in docker, which:
#
# * sets up ipv6 link-local only network
# * starts bash as the node user
# * exports some environment variables

# remove public ip address
export public=$(ip addr show eth0 | grep -oE '[0-9.]+/16')
ip addr del ${public} dev eth0
export ssb_host=$(ip addr show eth0 | grep -oE 'fe80[0-9a-f:]+')

# start bash as node user
/bin/bash -c "env ssb_appname=$ssb_appname ssb_host=$ssb_host su -l node"
