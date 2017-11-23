# Prerrequisites

Based on ```https://github.com/rails/rails-dev-box/```.

- VirtualBox
- Vagrant

# How It Works

# Setup

## Create VM

```
$ vagrant up
```

You can also specify the amount of memory or number of CPUs you would like to use by using environment variables. By default it allocates 2048Mb of RAM and 2 CPUs:

```
$ TIMESHEET_DEV_BOX_RAM=4096 TIMESHEET_DEV_BOX_CPUS=1 vagrant up
```

## Initialise timesheet_approval

```
$ vagrant ssh
$ cd /vagrant/timesheet_approval
$ bundle install
```