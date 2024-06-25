# Learning about Keepalived

This purpose of this repo is ultimately setting up a test bench to learn about keepalived.  The process that will be used induce a failover will be a Docker registry running as a container.

# Prerequisites

This repo was tested on an Ubuntu 22.04 server which had the following key components installed:

- LXD 5.21.1 LTS
- Ansible 2.10.8

# Make File

This repo contains a Makefile in order to reduce the development cycles as much as possible.  The `help` target is run if no arguments are passed to `make`:

```shell
$ make

Keepalived Environment Setup

Targets:
  LXD VM Operations
    create-ip-profiles            Create custom LXD profiles for static IP addresses
    delete-ip-profiles            Delete custom LXD profiles for static IP addresses
    deploy-vms                    Deploy the LXD VMs
    destroy-vms                   Destroy the LXD VMs
    reset-vms                     Delete and recreate all LXD objects for the VMs
  Ansible Operations
    ansible-ping-host             Execute an ansible ping against the host
    ansible-ping-vms              Execute an ansible ping against the LXD VMs
    ansible-host-prep             Prepare the host operating system
    ansible-docker-vm-install     Install docker and start a registry on each VM
    ansible-keepalived-apt        Install keepalived from apt repos
    ansible-keepalived-src        Install keepalived from source
    ansible-vm-prep               Install docker and keepalived
  Complete Build
    complete-build                Recreate VMs and then deploy docker and keepalived
  Help
    help                          Show this help.
```

Two different installation methods for `keepalived` are supported.  The version in the Apt repos is v2.2.4

```shell
$ apt search keepalived
Sorting... Done
Full Text Search... Done
keepalived/jammy 1:2.2.4-0.2build1 amd64
  Failover and monitoring daemon for LVS clusters
```

This version was released in May of 2021 according the [changelog](https://www.keepalived.org/download.html).

Version v2.3.1 was released in May of 2024.  As of the time of this writing (06/22/2024), the source installation option for keepalived is not working and still needs further development.  The Apt option though does produce a working intallation of `keepalived`.  The below logs were taken from the configured BACKUP server and the primary was rebooted:

```shell
Every 2.0s: systemctl status keepalived.service                                                      ka02: Sat Jun 22 15:10:28 2024

● keepalived.service - Keepalive Daemon (LVS and VRRP)
     Loaded: loaded (/lib/systemd/system/keepalived.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-06-22 14:51:19 UTC; 19min ago
   Main PID: 4457 (keepalived)
      Tasks: 2 (limit: 4367)
     Memory: 2.2M
        CPU: 141ms
     CGroup: /system.slice/keepalived.service
             ├─4457 /usr/sbin/keepalived --dont-fork
             └─4458 /usr/sbin/keepalived --dont-fork

Jun 22 14:51:19 ka02 Keepalived[4457]: Startup complete
Jun 22 14:51:19 ka02 systemd[1]: Started Keepalive Daemon (LVS and VRRP).
Jun 22 14:51:19 ka02 Keepalived_vrrp[4458]: (docker) Entering BACKUP STATE (init)
Jun 22 14:51:20 ka02 Keepalived_vrrp[4458]: Quorum lost for tracked process registry
Jun 22 14:51:20 ka02 Keepalived_vrrp[4458]: (docker) Entering FAULT STATE
Jun 22 14:51:21 ka02 Keepalived_vrrp[4458]: Quorum gained for tracked process registry
Jun 22 14:51:21 ka02 Keepalived_vrrp[4458]: (docker) Entering BACKUP STATE
Jun 22 15:09:36 ka02 Keepalived_vrrp[4458]: (docker) Entering MASTER STATE
Jun 22 15:09:52 ka02 Keepalived_vrrp[4458]: (docker) Master received advert from 10.196.3.1 with higher priority 254, ours 245
Jun 22 15:09:52 ka02 Keepalived_vrrp[4458]: (docker) Entering BACKUP STATE
```

# References

The below series of articles was helpful in getting the keepalived configuration right to track a process:

- [one](https://www.redhat.com/sysadmin/ha-cluster-linux)
- [two](https://www.redhat.com/sysadmin/keepalived-basics)
- [three](https://www.redhat.com/sysadmin/advanced-keepalived)