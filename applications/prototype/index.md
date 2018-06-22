# Baculus

## Phase II Submission

### Links to Public Documentation

Public Website https://jedahan.com/baculus

Code Repository https://github.com/baculus-buoy/baculus

Design Documents https://jedahan.com/baculus/research

Video test https://vimeo.com/jedahan/

### Solution Statement (570/500)

Baculus is a portable internet provider that allows people to communicate equally well whether nodes have intermittent connections to each other. It is a backpack with both local and long-range wifi, a solar, DC, and AC chargeable battery, and a raspberry pi running and offline-first web application that helps people connect and share messages quickly. No node is special, and when any node goes down, a map alerts those nearby to ask them to move to a point where nodes can reconnect. Even offline you can send messages and once there is a local connection they sync.

### Community/Location (433/1250)

The main community we have designed for is the neighborhood of Red Hook, Brooklyn, which has not changed since the beginning of the design. To contrast with the flooding scenario design, and to test that our template is adaptable to other situations, we have built one of the backpacks with a rural desert climate in mind, adding solar power and eschewing waterproofing, but the only test we have been able to do is in prospect park.

### Live Demo (/500)

We would be very excited to do a live demo of the current state of the system.

### Technical Feasability (/5000)

We learned a lot building this prototype, and are confident that there are many places to improve the state of truly independent communications infrastructure.

Each raspberry pi is running scuttlebot - forum software that can discover and share messages even in a link-local network. This opened up the opportunity for us to build a routerless network - the ubiquiti hardware are all setup as bridges, so no node is special. To make networking easier, we use cjdns to provide unique ipv6 addresses for each pi.

If you have a raspberry pi 3 b+ around (ideally two :) ), we invite you to follow the getting started guide to poke around the current software and networking.

### Differentiation (/1250)

### Affordability (/1250)

### Social Impact (/1250)

### Sustainability and scalability (/1250)

### Speed (/500)

### Openness (/1250)

We have been developing in the open in a lot of different ways:

* sharing progress on the scuttlebutt main network
* uploading work in progress on github
* participating in the peer-to-peer web conference, soliciting feedback

We would like to continue working on improving the projects we rely upon, especially the UX and decentralization capabilities of 



There are a few things we would like to improve on our prototype:

* switching to ubiquiti mesh nodes to make failover easier
* working on integrating the map UX with scuttlebutt
* improving the UX of scuttlebutt



### Portability (/1250)

The backpacks we have built range from 5-9kg, and are meant to be carried on the back. The majority of the weight is from the battery, which is easily swappable to fit different power/weight/cost needs.

### Power (778/1250)

We have done a run-down of the network in its current state, and with the 288Wh battery have gotten 48 hours of use. We have not had the time to start investigating power savings, but we are confident that we can hit our original goal of 72 hours even adding a planned additional SDR.

If we are able to continue development, a second mode meant for long term power will be tested. We plan on creating a duty cycle of 50% (either 12hr or 10min cycles, depending on use case) to bring total power consumption to require less than what can be provided by a single solar panel with 4 hours of sunlight a day. This seems feasable due to the nature of scuttlebutt.

Other more traditional power savings will be investigated as well (turning off peripherals on the pi, for example).

### Density and Range (/1250)

We have tested our prototype with small 

The ubiquiti gear we have used gets 100kb/s over 43km with perfect line of sight, which is plenty for scuttlebutt. We get 300Mbps at 20m.

### Applications (/1250)

Our hope is that, by providing solid, offline-first applications by default, we encourage neighborhood-sized interaction.