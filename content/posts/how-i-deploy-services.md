+++
draft = false
title = "Deploying Services Using SystemD: Part 0 of 3"
date = "2024-11-01T20:20:20-07:00"
author = "Carson Call"
cover = ""
tags = ["devops", "guide", "sysadmin"]
keywords = ["systemd"]
description = "An introduction to SystemD"
showFullContent = false
readingTime = false
hideComments = false
+++

## Introduction: What SystemD is, and why it's the GOAT
Welcome! This is the introduction to a series of posts about how to deploy all kinds of services on Linux using [SystemD](https://en.wikipedia.org/wiki/Systemd). From their website:

> systemd is a suite of basic building blocks for a Linux system. It provides a system and service manager that runs as PID 1 and starts the rest of the system.
> 
> systemd provides aggressive parallelization capabilities, uses socket and D-Bus activation for starting services, offers on-demand starting of daemons, keeps track of processes using Linux control groups, maintains mount and automount points, and implements an elaborate transactional dependency-based service control logic. systemd supports SysV and LSB init scripts and works as a replacement for sysvinit.
> 
> Other parts include a logging daemon, utilities to control basic system configuration like the hostname, date, locale, maintain a list of logged-in users and running containers and virtual machines, system accounts, runtime directories and settings, and daemons to manage simple network configuration, network time synchronization, log forwarding, and name resolution.

Sounds complicated, right? Well, it's really quite easy to use. Best of all, nearly every major Linux distribution uses it by default, so you don't have to install anything or add any software to your pristine server.

SystemD is, in my opinion, the best thing to ever happen to Linux operating systems. This is a spicy take for some, as it is often criticized for not following the Unix philosophy of "one tool, one job". However, it's hard to argue with the results -- it's used by Debian, Fedora, NixOS, Ubuntu, RHEL, SUSE, Pop!\_OS, and most others. It is being used for hugely different use cases -- embedded, server, desktop, and automotive just to name a few. It uses a simple text-based configuration scheme (INI-like, for the MS-DOS greybeards). 

## How I use SystemD
SystemD is immensely powerful. It can be used to configure and manage nearly every aspect of a server, from networking, to booting, to provisioning containers. While other solutions for managing services exist out there, such as Docker, Kubernetes, etc., I am passionate about simple, elegant solutions -- and SystemD is that solution for me. 

In this series, I am going to describe how I use SystemD to manage all the services on my server. I'll go into depth on how to use SystemD to run and manage simple executables, containers, and virtual machines in a secure and centralized way. 

[Part 1: Running Simple Executables as Services]({{< relref "posts/deploying-executables-using-systemd.md" >}})