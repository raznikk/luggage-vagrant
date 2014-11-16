#!/usr/bin/env bash

if [ -f "/var/vagrant_provision" ]; then
	exit 0
fi


# Update the environment
echo "Updating the system..."
apt-get update >/dev/null 2>&1


# Install Git
echo "Installing Necessary utilities (git, curl, wget, drush)"
apt-get install -y git vim wget curl drush debconf-utils >/dev/null 2>&1


# Install Apache
echo "Installing Apache"
apt-get install -y apache2 >/dev/null 2>&1
/bin/cp /vagrant/files/etc_apache2_sites-available/default /etc/apache2/sites-available/default
service apache2 restart


# Install PHP
echo "Installing PHP"
apt-get install -y php5 php5-cli php5-mysql php5-gd >/dev/null 2>&1


# Install MySQL
echo "Installing MySQL with root password 'rootpw'"
echo 'mysql-server mysql-server/root_password password rootpw' | debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password rootpw' | debconf-set-selections
apt-get install -y mysql-server >/dev/null 2>&1


# Install Solr
echo "Installing Apache Solr"
apt-get install -y solr-jetty >/dev/null 2>&1
/bin/cp /vagrant/files/etc_default/jetty /etc/default/jetty
service jetty restart


# Install luggage
echo "Installing Luggage..."
echo "... removing /var/www directory"
rm -rf /var/www


echo "... downloading luggage to /var/luggage"
pushd /var
/usr/bin/git clone https://github.com/isubit/luggage.git
popd


echo "... linking /var/luggage to /var/www"
ln -sf /var/luggage /var/www


echo "... modifying .gitmodules file to use https:// rather than ssh:// for submodule pull"
pushd /var/luggage
	/bin/sed -i 's/git@github.com:/https:\/\/github.com\//' /var/luggage/.gitmodules
popd


echo "... building luggage"
pushd /var/luggage
	DBCREDS="root:rootpw" /bin/bash ./scripts/build_luggage.sh
popd


touch /var/vagrant_provision
