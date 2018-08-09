# Baculus

## Prototype Application

### Links to Public Documentation

Public Website https://jedahan.com/baculus

Code Repository https://github.com/baculus-buoy/baculus

Design Documents https://jedahan.com/baculus/research

Video test https://vimeo.com/jedahan/baculusShort

### Solution Statement

Baculus is a template in how to build portable network provider that allows neighbors to communicate without any other infrastructure. It is a backpack with both local and long-range wifi, a solar/DC/AC chargeable battery, and a raspberry pi running an offline-first web application that syncs locally.

A simple build can run independent of power for up to 72 hours.

No node is special, and when any node goes down, a map alerts those nearby to ask them to move to a point where nodes can reconnect.

### Community & Location

The main community we have designed for is the neighborhood of Red Hook, Brooklyn, which has changed little since we started. With hurricaine Sandy in mind, we waterproofed one backpack, and added telescoping poles to help angling rooftop to rooftop connections.

Communities with limited or non-existent internet access benefit the most, as baculus works fine independent of other networks, or with intermittent power. One collaborator has direct experience with the challenges running surveys in areas with limited internet in rural Senegal, Nigeria, and Myanmar.

Beyond disaster scenarios in the US, many communities around the world can use this off-grid communication system immediately in their everyday lives. In rural africa, people can read or share news, and community health workers can sync and monitor public health. We'd like to work with these communities in the future.

To contrast with the flooding scenario design, and to test that our template is adaptable to other situations, we have built one of the backpacks with a rural desert climate in mind, adding solar power and eschewing waterproofing. The only solar test we have been able to do is in prospect park but we plan on testing in the area around Sichuan.

### Live Demo

We would be very excited to provide a live demo of our current prototype.

### Technical Feasability

All the technologies, and design have been chosen with the following values in mind - **transparency & community friendliness**, **availability & affordability of hardware**, **documentation**, and **building platforms over products**. With this in mind, we have also decided to go with hardware and software we have already tested and worked, but with the goal that each could be replaced by more readily available pieces while still leveraging the rest of the system.

**Prototype Setup**

The basic hardware design includes a lithium ion battery powering a raspberry pi, coordinating a ubiquiti litebeam access point.

For the proof of concept, the raspberry pi provides four services:

1. a wifi access point
2. scuttlebot server
3. web-based scuttlebot client
4. ipv6 over cjdns autopeering service

The wifi access point is managed by hostapd,  which automatically shows the scuttlebot client to anyone connecting by being rendered in the captive portal. The client is optimized for low-power devices and phones, and is developed **on** a raspberry pi.

The scuttlebot server syncs over a link-local network, meaning we can have the ubiquiti antennaes setup in bridge mode, essentially acting as a big wireless switch. Cjdns provides a unique ipv6 address that allows new nodes to automatically discover each other without a central router.

##### Location sharing

Currently when a node goes down, the way to find a neighbor is a combination of using airOS8's airView and the compass direction of the antennae.

We support two additions to the current setup - an RTL-SDR for sharing GPS coordinates, and a limeSDR mini for OsmoBTS, providing LTE/GSM bridges in case a web browser is not available.

For running the SMS interface, we have built an openBTS cellular network, and had successfully gotten over 40 cell phones to autoconnect, receive broadcasts from a locally running web application, and send SMSs back during [arthackday](http://arthackday.net/projects/dantheman-messenger-of-god).

We were not able to integrate our Iridium research into the backpacks yet but have successfully received plain text transmissions on our laptops.

For location discovery, we have been working on an offline map interface whose designs can be seen on the main site. For directing where the backpack should be moved to, we are building a divining rod that lights up, vibrates, and shows how many minutes they should walk in that direction. It will be powered by the raspberry pi, and a non-digital compass will be embedded in case the electronics fail.

##### Challenges 

Though the system is usable in its current state, there are two main challenges we are excited to overcome to start working with community leaders to build out larger installs. The first is in sharing gps coordinates reliably between backpacks. Receiving plain text iridium messages is not yet reliable, and is just the first step in making sure it can be relied on. We still have to build  the physical divining rod, and experiment with SDR frequency scanning.

### Differentiation

The main technical differentiator between our system and existing ones is the lack of a router. By doing this, no node is special. Most networks grow to require some sort of routing, but our choice of scuttlebutt as the main chat application which works offline first, with cjdns for collisionless ipv6 addresses, there truly are no single points of failure.

Our original Design Concept was broad, but since then we have focused our efforts on helping 'neighborhood' sized communities. This means providing hardware, sotware, documentation, and entry points that work well for a group of people who can recognize each other by name, face, dress, and location.

We still intend to work on the self-repairability portion of the network (via GPS sharing), but decided it was lower priority than getting community software into people's hands first, and help make sure the network is useful before a disaster.

### Affordability

We were pretty close to the mark for our original estimates

**Semi-Permanent Bill of Materials**

| Part                                                         | Notes                       | Power | Weight | Cost     |
| ------------------------------------------------------------ | --------------------------- | ----- | ------ | -------- |
| [Raspberry Pi 3B+](https://www.adafruit.com/product/3775)    |                             | 690mA | 50g    | $35      |
| [16GB microSD](https://www.amazon.com/Sandisk-Ultra-Micro-UHS-I-Adapter/dp/B073K14CVB) |                             |       | 2g     | $10      |
| [ALFA usb wifi](http://a.co/5UL0Vl1)                         |                             | 200mA | 181g   | $35      |
| [Litebeam 5AC gen2](https://www.amazon.com/Ubiquiti-Networks-LBE-5AC-GEN2-US-Litebeam-23dBi/dp/B06Y2JH7PV/) | ~2km city range @ 4m height |       | 152g   | $70      |
| 5V Power Supply                                              | For pi                      |       |        | $8       |
| [Mr. Longarm Pole](https://www.amazon.com/gp/product/B00004YUPO) | 2m - 4m                     |       |        | $25      |
|                                                              | **Total**                   |       |        | **$183** |

**Base Bill of Materials**

| Part                                                         | Notes              | Weight | Cost     |
| ------------------------------------------------------------ | ------------------ | ------ | -------- |
| [Raspberry Pi 3B+](https://www.adafruit.com/product/3775)  |                    | 50g    | $35      |
| [16GB microSD](https://www.amazon.com/Sandisk-Ultra-Micro-UHS-I-Adapter/dp/B073K14CVB) |                    | 2g     | $8       |
| [ALFA usb wifi](http://a.co/5UL0Vl1)                         |                             | 181g | $35 |
| [Ubiquiti Mesh AC](https://www.amazon.com/Ubiquiti-Networks-UAP-AC-M-US-Wide-Area-Dual-Band/dp/B076B4ZVF2/ref=sr_1_4?s=electronics&ie=UTF8&qid=1533837131&sr=1-4&keywords=ubiquiti+mesh+ac&dpID=51-Rhp-ZYuL&preST=_SY300_QL70_&dpSrc=srch/) |                    | 162g   | $93      |
| [200WH Power Station](https://www.amazon.com/gp/product/B07BGZB9L5/) | AC and USB outlets | 2364g | $180  |
| [Clear Waterproof Backpack](https://www.amazon.com/gp/product/B01LZT7KFU/) |                    | 430g | $25      |
| [10x DC Power Jack Plugs](https://www.amazon.com/gp/product/B01J1WZENK/) |                    | 2g | $8/4     |
| [2x PoE Injector](https://www.amazon.com/BeElion-Passive-Injector-Splitter-Connector/dp/B01HMNJHII/ref=pd_sbs_421_1?_encoding=UTF8&pd_rd_i=B01HMNJHII&pd_rd_r=TF2GKJN950SDFQHE0D06&pd_rd_w=Jm3Lr&pd_rd_wg=xo9Nj&psc=1&refRID=TF2GKJN950SDFQHE0D06) |                    | 20g    | $8/2     |
| [12V-24V DC-DC Converter](https://www.amazon.com/gp/product/B00ID3TJ3U) | for litebeam       | 249g   | $16      |
| [12V-5V microUSB Converter](https://www.amazon.com/gp/product/B01MEESLZ6/) | for pi             | 46g    | $10      |
| [Mr. Longarm Pole](https://www.amazon.com/gp/product/B00004YUPO) | 2m - 4m            | 300g   | $25      |
|                                                              | **Total**          |        | **$465** |

##### Extended

| Part                                                         | Notes                             | Cost     |
| ------------------------------------------------------------ | --------------------------------- | -------- |
| [LimeSDR Mini](https://www.crowdsupply.com/lime-micro/limesdr-mini) | GSM/LTE base station + wayfinding | $180     |
| [RTL-SDR](https://www.amazon.com/RTL-SDR-Blog-RTL2832U-Software-Telescopic/dp/B011HVUEME) | Iridium Reciever                  | $25      |
| [Solar panel](https://www.amazon.com/gp/product/B0748GKHZ8/) | 80W @ 2.5kg                      | $110 |
| [Iridium LNA](http://adsbfilter.blogspot.com/2016/02/l-band-inmarsat-thuraya-iridium-gps.html) |  | $30 |
|                                                              | **Total**                         | **$810** |

### Social Impact

The system is designed to be useful year round, and only *extra* useful during emergencies. By not prescribing a single way to use it, the channel-style message board allows the community to use things as they see fit. We have talked with people who lived through hurricaine Sandy in Red Hook about the challenges they faced, and with representatives during Mozilla organized about recent challenges in Puerto Rico. The biggest takeaways we learned is that power infrastructure can be out for many months (not just a few days), that more connectivity options are preffered for reliability even if the device is more complex, and that help has to come in concert with the community.

Our prototype is particularly useful in communities where the only computing device may be older phones. For example, the scuttlebutt client we chose does not require javascript to work. We have written technical documentation for the software setup that assumes no prior technical knowledge, to help train those who are interested in making their own network.

There is no reliance on a single provider for any component, and no reliance on external guidance for the project to continue as long as it is useful.

### Sustainability and scalability

The only way for baculus to be sustainable is for it to be adopted by a community from within. In pursuit of this goal, the build logs are provided to show just one example of how to create a backpack. Instead of providing a drop-in solution to buy off the shelf, we've created educational materials, shared build logs, and generally strived to make sure our results are reproduceable. 

We have decided to call our guides 'Build Logs' to be more descriptive than perscriptive in how you setup the network.

The backpacks have plenty of extra room for community leaders and anyone else interested in stewarding the network to add other useful supplies, such as water, notebooks, medical supplies, etc.

The poles serve not only to provide better network links, but also to attract attention, highlight that infrastructure should be visible, accessible, and most of all hackable.

We have taken special care to make sure that all the tools we use are documented, all the scripts allow someone to bootstrap with a minimal amount of hardware. Our ultimate goal is that any new hardware can be provisioned completely from an existing node.

Everything is available off-the-shelf without the need for special partnerships.

### Speed

iperf3 tests show about 89Mbits download and upload running through the raspberry pi, and point to point links show 100Mbps at 500m to 450Mbps at 10m.

### Openness

We have been developing in the open in a lot of different ways:

* sharing progress on the scuttlebutt main network
* uploading work in progress to github, and tracking progress publicly
* participating in the peer-to-peer web conference, soliciting feedback
* our networks conference
* respecting upstream licenses, and licensing our work CC0 where possible, MIT otherwise
* taken up maintainership of open source projects such as PiBakery

We would like to continue our integration work with iridium for gps sharing, and improving on the projects we rely upon, such as scuttlebutt. Most importantly:

* switching to ubiquiti mesh nodes to make failover simpler
* integrating gps sharing over iridium
* creating a physical divining rod for ease of discovery
* testing in more locations
* working on integrating the map UX with scuttlebutt
* improving the UI of the patchfoo scuttlebutt client
* extending scuttlebutt autodiscovery to work over ipv6

If you have a raspberry pi 3 b+ around (ideally two :) ), we invite you to follow the readme on https://github.com/baculus-buoy/baculus to see how it all fits together.

### Portability

The backpacks we have built range from 5-13kg, and are meant to be carried on the back. The majority of the weight is from the battery, which is easily swappable to fit different power/weight/cost needs. The solar panel is <3kg, and one of the builds has wheels so it can be dollied around. Each can stand upright on their own, and include a telescoping pole meant to be setup in a semi-permanent manner.

### Power

We have done a run-down of the network in its current state, and with the 288Wh battery lasts 48 hours. We have not had the time to start investigating power savings, but we are confident that we can hit our original goal of 72 hours even adding the planned additional SDRs.

If we are able to continue development, a second mode meant for long term power will be tested. We plan on creating a duty cycle of 50% (either 12hr or 10min cycles, depending on use case) to bring total power consumption to require less than what can be provided by a single solar panel with 4 hours of sunlight a day. This seems feasable due to the nature of scuttlebutt.

Other more traditional power savings will be investigated as well (turning off peripherals on the pi, for example, eschewing the touchscreen).

### Density and Range

Each backpack in our working prototype can serve about 20 users at the same time in a 10m radius.

We have 3 working backpacks, which have been placed as far apart from one another as 500m.

With our current setup, we think it would be reasonable to have up to 50 backpacks in a network, that would cover an entire neighborhood, or a small village.

Due to the nature of scuttlebutt, users do not need to be online at the same time to send and receive messages reliably. So though the 50x20 number would imply only helping 1000 people, it would more likely provide a virtual community center reach of 5000.

### Applications

We provide an easy to use community messaging platform based on the open source scuttlebutt protocol. The web client exposed, is optimized for low power usage on both the pi and client devices such as phones.

The scuttlebutt network makes it easy for people to create new topics, and exposes a familiar feed-like interface with fast search capabilities.

With an upstream internet connection, the current prototype works fully with the regular internet.

We also provide a copy of wikipedia offline because its the world's collective knowledge and is useful in any situation.