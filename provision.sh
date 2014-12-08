#!/usr/bin/env bash

if [ -f "/var/vagrant_provision" ]; then
	exit 0
fi

# Update the environment
echo "Updating the system..."
apt-get update >/dev/null 2>&1

# Install utilities
echo "Installing Necessary utilities (git, wget, java, )"
apt-get install -y git vim nano wget php-pear debconf-utils openjdk-7-jre-headless >/dev/null 2>&1

# Install drush 5.10
echo "Installing Drush5.10"
pear channel-discover pear.drush.org 2>&1
pear install drush/drush-5.10.0.0 2>&1

# Install Apache
echo "Installing Apache"
apt-get install -y apache2 >/dev/null 2>&1
/bin/cp /vagrant/files/etc_apache2_sites-available/default /etc/apache2/sites-available/default 2>&1
service apache2 restart 2>&1

# Install PHP
echo "Installing PHP"
apt-get install -y php5 php5-cli php5-common php5-mysql php5-gd >/dev/null 2>&1

# Install MySQL
echo "Installing MySQL with root password 'rootpw'"
echo 'mysql-server mysql-server/root_password password rootpw' | debconf-set-selections 2>&1
echo 'mysql-server mysql-server/root_password_again password rootpw' | debconf-set-selections 2>&1
apt-get install -y mysql-server >/dev/null 2>&1

# Install Solr
echo "Installing Apache Solr"
pushd /tmp
	wget https://archive.apache.org/dist/lucene/solr/4.10.2/solr-4.10.2.tgz

	pushd /var
		tar xzvf /tmp/solr-4.10.2.tgz 2>&1
		git clone http://git.drupal.org/project/apachesolr.git
	popd

	pushd /var/solr-4.10.2/
		mkdir ./example/solr/luggage1
		cp -R /var/apachesolr/solr-conf/solr-4.x/* ./example/solr/collection1
	popd

	/var/solr-4.10.2/bin/solr start -p 8983
popd

# Install luggage
echo "Installing Luggage..."
echo "... changing to /var directory"
pushd /var

  echo "... removing native /var/www"
  rm -Rf /var/www 2>&1

  echo "... downloading luggage to /var/www"
  /usr/bin/git clone https://github.com/isubit/luggage.git www 2>&1

  echo "... changing to ./www directory"
  cd www

  echo "... modifying .gitmodules file to use https:// rather than ssh:// for submodule pull"
  sudo /bin/sed -i 's/git@github.com:/https:\/\/github.com\//' /var/www/.gitmodules 2>&1

  echo "... making build script executable"
  sudo chmod a+x ./scripts/build_luggage.sh 2>&1

  echo "... running build script"
  APACHEUSER="www-data" DBCREDS="root:rootpw" /bin/bash ./scripts/build_luggage.sh 2>&1

popd

# Final permissions check
echo "Ensuring permissions are correct..."
chown -R www-data:www-data /var/www

touch /var/vagrant_provision
