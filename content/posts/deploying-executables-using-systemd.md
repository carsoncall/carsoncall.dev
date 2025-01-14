+++
draft = false
title = "Deploying Services using systemd: Part 1 of 3 -- Executables"
date = "2025-01-12T17:50:40-07:00"
author = "Carson Call"
cover = ""
tags = ["devops", "guide", "sysadmin"]
keywords = ["deploy", "systemd"]
description = "How I use SystemD to deploy simple executables as services"
showFullContent = false
readingTime = false
hideComments = false
+++
## Intro
This guide is designed to help the reader get started with deploying any executable as a systemd service. For an intro to SystemD, see [Deploying Services Using systemd: Part 0 of 3]({{< ref "posts/how-i-deploy-services.md" >}})

The goal here is to deploy any arbitrary executable as a long-running, monitored service with systemd. If you can run it on the command line, you can run it with systemd. 
There are two kinds of services that will be discussed here -- system services, and user services. While these terms are very ambiguous, for our purposes a system service is a process that must have root permissions to fulfill its purpose, while a user service does not require root privileges. Generally, one should try to use user services wherever possible, due to the security benefits.

However, there are legitimate reasons to run a service as root. One common example is to bind to low-numbered ports, like 443 for HTTPS. Another example is to perform privileged operations, such as accessing certain hardware devices. There are ways around this (see the `setcap` command) but they are beyond the scope of this post. 

> While user services are generally more secure, remember that the files a hacker would want to exfiltrate are often owned by "your" user. For example, on my Linux desktop machines, running a user service under my own user is still not a good idea, because if the service was hacked, the hacker potentially could read almost anything in my home directory. That includes SSH keys, API keys in .config/, documents such as tax returns, etc. So it's important to make new users!

### Step 1:  (Optional) Create a new user for your service
This allows you to leverage Linux's default discretionary access control (DAC) enforcement to further isolate your service in the event of compromise. If you are running this service as root, you can skip these steps.
1. Create a new user:
```bash
sudo useradd jellyfin
```
2. Then, we must give the new user long-running service permissions:
```bash
loginctl enable-linger jellyfin
```
3. Finally, switch to the new user's shell to finish configuring the service:
```bash 
machinectl shell jellyfin@
```
4. User services, regardless of whether they're containerized, are configured with files located in:
```bash
cd ~/.config/systemd/user/*
```
### Step 2: Create a  service file
These are very simple to run with systemd. I'll give an example of the simplest possible configuration file, to show only the required fields:
```toml
# ~/.config/systemd/user/simple.service -- for user services
# /etc/systemd/system/simple.service -- for services running as root
[Unit]
Description=Simple Service

[Service]
ExecStart=/usr/bin/example-command

[Install]
WantedBy=default.target
```
This will run your command, managing logging, child processes, resource usage, and more for you. 

Here's an example of a more comprehensive service file:
```toml
# ~/.config/systemd/user/example.service -- for user services
# /etc/systemd/system/example.service -- for services running as root
[Unit]
Description=Example Long-Running Service
Documentation=https://example.com/docs
After=network.target

[Service]
# Example command to execute before starting the service
ExecStartPre=/usr/bin/mount /dev/your/device

# Prefixing with a '-' means that the service will continue to start up, even if this service fails
ExecStartPre=-/usr/bin/neofetch

# The command to start the service
ExecStart=/usr/bin/example-command --option value

# A command to be executed after the service starts
ExecStartPost=/usr/bin/pop-champagne

# A command to be executed to stop the service
ExecStop=/usr/bin/torpedo

# Restart the service if it crashes
Restart=on-failure

# Time to wait before restarting the service
RestartSec=5s

# Environment variables
Environment="ENV_VAR1=value1"
Environment="ENV_VAR2=value2"

# Working directory
WorkingDirectory=/home/username/example-directory

# User and group to run the service as
User=username
Group=groupname

# Timeout settings
TimeoutStartSec=30
TimeoutStopSec=30

# Kill the process if it doesn't stop within the timeout
KillMode=control-group # see man systemd.kill

[Install]
# Targets to start the service
WantedBy=default.target
```
For full documentation of all the possible options, see `man systemd.service`. Honestly, ChatGPT is pretty good at generating these for you, so I wouldn't start in the manpages (they are VERY detailed). Instead, have ChatGPT generate it for you, and if you want to see what each option does, look it up in the manpages. Sometimes our AI overlords will hallucinate options, especially as you ask it for more specific or niche functionality -- that's when you should bust out the man pages. 

### Step 3: Start the service
These steps are used all the time for starting and stopping services of all kinds. Omit the `--user` flag and use `sudo` before each command if you are creating a root service.
First, tell systemd to go reread all of the service files (now that there's a new one):
```bash
systemctl --user daemon-reload
```
Then, start your service:
```bash
systemctl --user start your-service.service
```
> you can skip the '.service' part of the incantation, and systemd will assume you mean a service file. There are other types of systemd units, though, so it's good practice to always include the unit type.

(Optional) to make your service automatically start at boot:
```bash
systemctl enable your-service.service
```
> Pro Tip: you can simultaneously enable and start your service by using `systemctl enable --now your-service`

### Step 4: (Optional) Ensure that your service is available
I include this step because I always forget it :joy:
If your service is a web service, then you should make sure you open the port in the firewall. Debian-based distros often use `ufw` (Uncomplicated Firewall) while Fedora/RHEL-based distros use `firewall-cmd` (Systemd-firewalld).

If you are running SELinux and your service isn't working right, you can check whether there have ben SELinux denials using:
```bash
sudo ausearch -m avc -ts recent
```

To see the logs of your service:
```bash
journalctl -xeu your-service.service
```
> `-x` to give explanations where available, `-e` to start from the end of the log, and `-u` to specify only logs for the given unit


That's pretty much it! Not bad, right?



-- Carson