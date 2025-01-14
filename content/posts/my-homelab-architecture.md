+++
draft = false
title = "My Homelab Architecture"
date = "2023-11-14T19:44:33-07:00"
author = "Carson Call"
cover = ""
tags = ["hardware", "homelab", "DIY"]
keywords = ["rack mount", "dell"]
description = "How I built a surprisingly robust infrastructure out of very cheap hardware"
showFullContent = false
readingTime = false
hideComments = false
+++

{{< image src="/images/homelab-rack-front-open.webp" alt="Carson Call's Profile Picture" position="center" style="border-radius: 8px; width:50%;" >}}
{{< image src="/images/homelab-rack-back-open.webp" alt="Carson Call's Profile Picture" position="center" style="border-radius: 8px; width:50%;" >}}

There it is! My homelab. As a poor college student, I have hacked together quite a bit of junk into the beauty that you see here :joy:

The rack is a Tripp-Lite SRW12US 12U wall-mount network rack. I got it on KSL (Utah's Craigslist) for like $200. It's mounted on castor wheels, so that I can move it around easily. 

When I first got into the homelab game, I didn't know that there was a difference between network racks and server racks. I bought this thinking it would be great to put a few servers in, until I actually bought a server and realized that it was ten inches longer than my rack. Oops! Luckily, it was nothing that a Dremel and permanent damage to my hearing couldn't fix :joy:

The interior hardware, starting from the top:
1. A 1U surge protector of unknown origin or model. I bought this for like $20 from a place here called GCB Computers. I understand that it was initially for analog music electronics, so it is also a "power cleaner"; the surge protection wears off apparently with no indication of it wearing off. So, honestly, it's probably only a rack-mounted power strip at this point. 
2. A 1U TP-Link TL-SG1016DE Gigabit desktop switch. I bought a rackmount kit for it on Amazon :sweat_smile:. It is rear-mounted, because the Ethernet cables were too prominent to close the front of the rack when it was mounted in the front. Plus, all of the things it connects have Ethernet ports on the back.
3. A 2U rack shelf, currently infested with the undead remains of an old (like 2014) Dell Optiplex SFF PC. This corpse of a machine is possessed by OPNSense, and carries out its eternal punishment as my router/firewall/reverse proxy. I got this machine from a university surplus sale for like $50. With 4 cores/4 threads, 8GB RAM, and a few PCIE expansion slots, it provides a very robust and powerful firewall/router for very cheap. People who buy expensive machines for firewalls are suckers. The reason the PC looks like it was cut in half is because it, in fact, was cut in half. I cut off the front of the case, with the disk drives, 5" hard drives, etc. to save space, since I wasn't using any of that hardware. It reduced the size of the machine by about half, which was worth it for me. This shelf currently takes up about 3.5 U, mostly for historical reasons, which I could cut down if I needed to. 
4. My gaming rig. It's got a mATX motherboard, an Intel i7-1170k, 32GB DDR4 RAM, and an AMD Radeon RX 6800 GPU. This machine is a trooper! When I decided to rack-mount the world, I wanted to buy a case for it SO BAD from [Sliger](https://www.sliger.com/products/rackmount/3u/cx3171a/) (Sponsor me!!). However, their cases that fit a full gaming GPU are around $300, which is more than I spent on all of the the above (lol!) so I decided to go the much more... DIY solution. I took a $20 Amazon [test bench case](https://www.amazon.com/ALAMENGDA-Computer-Motherboards-Dissipation-Accessories/dp/B0C59W6JKD?crid=9L5E102WEQCN&dib=eyJ2IjoiMSJ9.z_yoYGQaJdG3Qi_QDtNIYhOp2Xciu8iOXqugmbUNqVt8wzCL5UV-EMtnA6vP-iM2IuxDARIDUzVEDzOjRsPYYz6kPXy2ChDujTs9KS_ifXBn3wyA9jLRocpImtAHJT-u-X-35_QO4ae4JUryDQox7seY5Ibvvomo_F9hvP8p6-jpMWrK2i69-HFN0ts7YVaJA7KJent9cB1zj4GYAId572lduq_1-MjrkVfdWNphZwA.2unKs9tiGja93UUKr3-Dq0wd0em0UA57RDe8NK7lyP0&dib_tag=se&keywords=test+bench+pc+case&qid=1736877635&sprefix=test+bench+%2Caps%2C178&sr=8-1) and drilled a few holes in a pair of steel right-angle joints (used for building things like backyard decks), and, vóila! Rack mount case! This machine is currently serving a Windows desktop over Sunshine with Tailscale, allowing me to game on any machine, anywhere. I'll write another post about how I got that working soon.
5. My server. It's an old Dell R720 PowerEdge, with 128 GB of DDR3, two 8 core/16 thread CPUs, a 10Gbps SFP+ fiber optic connection, and a AMD Radeon RX 6600 XT. I got this thing for $120! This machine used to have a front as well, with a single HDD bay with 8x2.5" SAS HDDs, but after playing the Used Datacenter Drive :tm: game for a few months, I decided that I didn't want to deal with Dell's drive pricing bullshit and switched to a NVMe-based regime. While NVMes are expensive, they are much more reliable. Plus, they are used in all of my other machines, which gives me flexibility to reuse drives when I upgrade! Plus they're very fast. Most importantly, they don't sound like a typewriter having a seizure whenever they are written to, which is good for my mental health. Once I decided to get rid of the HDD bays, I chopped off the front of the server with the aforementioned Dremel of Chopping. Now, it (barely) fits inside of my 20.5" rack! I'll write another post about my experience with that as well.
For internet connectivity, I am blessed with Google Fiber. Right now, I am just using the 1Gbps symmetrical plan, which is plenty for me. 

All jokes aside, the main thing I want to convey here is *just how cheap hardware is nowadays*. I have hosted services for startups, all of my own websites, my own cloud gaming service, home automation, and more, simultaneously, with just the stuff you have seen here. Excepting the gaming computer, I think that I've spent like $600 total on the whole setup. That's probably the cost of running this amount of compute on AWS for like 6 hours. 

***Remember kids, the only clouds are in the sky. Everything else is just someone else's computer***.

-- Carson