# baculus backpack

### TO DO:
* Raspberry pi comms
  * DONE - Ping with two pi's over wifi(liteBeam)
* Concept art
  * DONE
* Test outside
  * DONE - Hyperlapse video made

## Purchase links:

* [Router](https://www.amazon.com/MikroTik-Routerboard-RB960PGS-Gigabit-Ethernet/dp/B01MDUCLVW/ref=sr_1_15?s=electronics&ie=UTF8&qid=1508354776&sr=1-15&keywords=mikroTik)
* [7.5" eInk display](https://www.amazon.com/HAT-Resolution-Electronic-Controller-Compatible/dp/B0769XXSXR/ref=pd_sbs_147_4?_encoding=UTF8&pd_rd_i=B0769XXSXR&pd_rd_r=JS3SW50WZBW2603P3H3Y&pd_rd_w=3Ngy4&pd_rd_wg=EvAOf&psc=1&refRID=JS3SW50WZBW2603P3H3Y)
* [4.2" eInk display](https://www.amazon.com/waveshare-Resolution-Electronic-Interface-Raspberry/dp/B0751J99PS/ref=pd_sbs_147_5?_encoding=UTF8&pd_rd_i=B0751J99PS&pd_rd_r=JS3SW50WZBW2603P3H3Y&pd_rd_w=3Ngy4&pd_rd_wg=EvAOf&psc=1&refRID=JS3SW50WZBW2603P3H3Y)
* [Clear top junction box](https://www.amazon.com/uxcell-290mm-Dustproof-Electrical-Junction/dp/B072172XV6/ref=sr_1_21?ie=UTF8&qid=1526272919&sr=8-21&keywords=ip65+box+clear)

## Resources

#### Setting up P2P connection between raspberry pi's

Used P2P connection as described in ubiquity guide [here](https://help.ubnt.com/hc/en-us/articles/205142890-airMAX-How-to-Configure-a-Point-to-Point-Link-Layer-2-Transparent-Bridge-). Used a physical netgear router to assign IP addresses.

#### Hotspot

Followed [this](https://howtoraspberrypi.com/create-a-wi-fi-hotspot-in-less-than-10-minutes-with-pi-raspberry/) guide. Was not successful.

#### Ubiquity map API - [link](https://link.ubnt.com/)

## Troubleshooting:

#### Issue : Raspberry Pi uses ethernet as default interface device to access internet instead of wifi - [Solution:](https://raspberrypi.stackexchange.com/questions/15119/force-raspberry-to-get-internet-from-specific-network)

Specifically: Check default default route with  

      netstat -rn

Then delete default route

      sudo route del default

Add new default route

    sudo route add default gw 172.20.10.1

#### Issue: unable to update raspberry pi - [Solution](https://askubuntu.com/questions/899009/sudo-apt-update-always-giving-clearsigned-file-isnt-valid-got-nosplit-does)
