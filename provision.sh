#!/usr/bin/env bash

if [ -f "/var/vagrant_provision" ]; then
	exit 0
fi


# Update the environment
echo "Updating the system..."
apt-get update >/dev/null 2>&1


# Install Git
echo "Installing Necessary utilities (git, curl, wget, drush)"
apt-get install -y git vim wget php-pear debconf-utils >/dev/null 2>&1
echo "Installing Drush 5.10"
pear channel-discover pear.drush.org
pear install drush/drush-5.10.0.0

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
pushd /tmp
wget https://archive.apache.org/dist/lucene/solr/4.10.2/solr-4.10.2.tgz
	pushd /var
		tar xzvf /tmp/solr-4.10.2.tgz 
	popd

	pushd /var/solr-4.10.2/
		cp -R /var/luggage/sites/all/modules/apachesolr/solr-conf/solr-4.x/* ./example/solr/conf
	popd

	/var/solr-4.10.2/bin/solr start -p 8983
popd




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


echo "... installing the drupal system"
pushd /var/luggage
	drush site-install -qy minimal --db-url=mysql://root:rootpw@localhost/drupal
popd


echo "... building luggage"
pushd /var/luggage
	DBCREDS="root:rootpw" /bin/bash ./scripts/build_luggage.sh
popd


touch /var/vagrant_provision
