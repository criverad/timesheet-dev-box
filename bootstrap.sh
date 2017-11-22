#!/bin/bash

# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

# FIXME: This addresses an issue with Ubuntu 17.10 (Artful Aardvark). Should be
# revisited when the base image gets upgraded.
#
# Workaround for https://bugs.launchpad.net/cloud-images/+bug/1726818 without
# this the root file system size will be about 2GB.
echo expanding root file system
sudo resize2fs /dev/sda1

echo adding swap file
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

# # The weird command below performs a non-interactive upgrade, but it introduces
# # some options that will prevent an interactive Grub screen from messing with
# # the upgrade process.
# echo upgrading system dependencies...
# DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

echo updating package information
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
add-apt-repository -y ppa:webupd8team/java >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential

install Ruby ruby2.2 ruby2.2-dev
update-alternatives --set ruby /usr/bin/ruby2.2 >/dev/null 2>&1
update-alternatives --set gem /usr/bin/gem2.2 >/dev/null 2>&1

echo installing current RubyGems
gem update --system -N >/dev/null 2>&1

echo installing Bundler
gem install bundler -N >/dev/null 2>&1

install Git git
# install SQLite sqlite3 libsqlite3-dev
# install memcached memcached
# install Redis redis-server
# install RabbitMQ rabbitmq-server

# install PostgreSQL postgresql postgresql-contrib libpq-dev
# sudo -u postgres createuser --superuser vagrant
# sudo -u postgres createdb -O vagrant activerecord_unittest
# sudo -u postgres createdb -O vagrant activerecord_unittest2

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
install MySQL mysql-server libmysqlclient-dev
# Set the password in an environment variable to avoid the warning issued if set with `-p`.
MYSQL_PWD=root mysql -uroot <<SQL
GRANT ALL ON dius_timesheet.* to 'dius_timesheet'@'localhost' IDENTIFIED BY 'dius_timesheet';
SQL

# install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
# install 'Blade dependencies' libncurses5-dev
# install 'ExecJS runtime' nodejs

# Installing Java 7 (what a drag):
wget -q http://ftp.osuosl.org/pub/funtoo/distfiles/oracle-java/jdk-7u80-linux-x64.tar.gz
JVM_DIR=/usr/lib/jvm
mkdir -p $JVM_DIR
tar xvf ./jdk-7u80-linux-x64.tar.gz -C $JVM_DIR
JAVA_DIR=$JVM_DIR/jdk1.7.0_80
update-alternatives --install /usr/bin/java java $JAVA_DIR/bin/java 1
update-alternatives --install /usr/bin/javac javac $JAVA_DIR/bin/javac 1

# Ready to install rails
echo installing Rails
gem install rails -v 3.2.22 >/dev/null 2>&1

echo 'all set, rock on!'