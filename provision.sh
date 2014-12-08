#!/usr/bin/env bash

if [ -f "/var/vagrant_provision" ]; then
	exit 0
fi


# Update the environment
echo "Updating the system..."
apt-get update >/dev/null 2>&1


# Install utilities
echo "Installing Necessary utilities (git, wget)"
apt-get install -y git vim nano wget php-pear debconf-utils >/dev/null 2>&1
echo "Installing Drush5.10"
pear channel-discover pear.drush.org
pear install drush/drush-5.10.0.0

# Install Apache
echo "Installing Apache"
apt-get install -y apache2 >/dev/null 2>&1
/bin/cp /vagrant/files/etc_apache2_sites-available/default /etc/apache2/sites-available/default
service apache2 restart

# Install PHP
echo "Installing PHP"
apt-get install -y php5 php5-cli php5-common php5-mysql php5-gd >/dev/null 2>&1

# Install MySQL
echo "Installing MySQL with root password 'rootpw'"
echo 'mysql-server mysql-server/root_password password rootpw' | debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password rootpw' | debconf-set-selections
apt-get install -y mysql-server >/dev/null 2>&1

# Install Solr
# echo "Installing Apache Solr"
# apt-get install -y solr-jetty >/dev/null 2>&1
# /bin/cp /vagrant/files/etc_default/jetty /etc/default/jetty
# service jetty restart

# Install luggage
echo "Installing Luggage..."
echo "... changing to /var directory"
pushd /var
  echo "... removing native /var/www"
  rm -Rf /var/www
  echo "... downloading luggage to /var/www"
  /usr/bin/git clone https://github.com/isubit/luggage.git www

  echo "... changing to ./www directory"
  cd www
  echo "... modifying .gitmodules file to use https:// rather than ssh:// for submodule pull"
  sudo /bin/sed -i 's/git@github.com:/https:\/\/github.com\//' /var/www/.gitmodules
  echo "... making build script executable"
  sudo chmod a+x ./scripts/build_luggage.sh
  echo "... running build script"
  APACHEUSER="www-data" DBCREDS="root:rootpw" /bin/bash ./scripts/build_luggage.sh
popd

touch /var/vagrant_provision
