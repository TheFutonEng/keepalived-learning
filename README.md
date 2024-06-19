# keepalived-learning

Learning about Keepalived.

# Repo Structure

A lot of this learning will leverage Ansible to be able to quickly automate a full environment spin up / tear down.

# LXD VM Creation

```shell
$ lxc launch ubuntu:22.04 ka01 --vm -c limits.cpu=2 -c limits.memory=4GB --config=user.user-data="$(cat cloud-init/user-data)"
$ lxc launch ubuntu:22.04 ka02 --vm -c limits.cpu=2 -c limits.memory=4GB --config=user.user-data="$(cat cloud-init/user-data)"
```

# Testing

Confirm Ansible can interact with the `berkeley` node:

```shell
$ ansible -b -i inventory.yaml -m ping lxd_host
```

Confirm Ansible can interact with the virtual machines:

```shell
$ ansible -b -i inventory.yaml -m ping lxd-vms
```