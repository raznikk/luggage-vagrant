# Luggage-Vagrant

Luggage-Vagrant is a simple setup script for the vagrant system that will install the luggage suite (found at https://github.com/isubit/luggage).

This system has been built to help in Luggage development and to give DevOps a simple way to install and test this software.

Since vagrant has so many back-end virtualization options, this may end up becoming a large part of a docker container setup.

## Prerequisites
  * VirtualBox - https://www.virtualbox.org/wiki/Downloads
  * Vagrant - https://www.vagrantup.com/

## Installation
  * clone this repo
  * ```cd ./luggage-vagrant```
  * run ```vagrant up```

## Accessing the installation
  * Point your browser to http://localhost:8080, and the initial login page should pop up.
  * To log in as the administrative user,
    * run ```vagrant ssh``` to ssh into the luggage virtual machine
    * run ```cd /var/www```
    * run ```drush uli```. This will generate a one-time authentication string which you can use to log into the system and change the admin password.

## Further Documentation
Further Documentation on Luggage can be found at http://www.biology-it.iastate.edu/luggage_doc/
