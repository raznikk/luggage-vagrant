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
/bin/cp /vagrant/files/default /etc/apache2/sites-available/default
service apache2 restart

# Install PHP
echo "Installing PHP"
apt-get install -y php5 php5-cli php5-mysql php5-gd >/dev/null 2>&1

# Install MySQL
echo "Installing MySQL with root password 'rootpw'"
echo 'mysql-server mysql-server/root_password password rootpw' | debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password rootpw' | debconf-set-selections
apt-get install -y mysql-server >/dev/null 2>&1

# Install drush
echo "Installing drush"
apt-get install drush

# Install luggage
echo "Installing Luggage..."
echo "... removing /var/www directory"
rm -rf /var/www

echo "... downloading luggage to /var/luggage"
pushd /var
/usr/bin/git clone https://github.com/raznikk/luggage.git

echo "... linking /var/luggage to /var/www"
ln -sf /var/luggage /var/www

echo "... installing the drupal system"
pushd /var/luggage
drush site-install -qy standard --db-url=mysql://root:rootpw@localhost/drupal

echo "... building luggage"
DBCREDS="root:rootpw" /bin/bash ./scripts/build_luggage.sh
popd
popd

touch /var/vagrant_provision
