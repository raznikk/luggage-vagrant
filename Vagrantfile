# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  
  config.vm.provider "virtualbox" do |vbox|
    vbox.memory = 1024
    vbox.cpus = 2
  end

  # changed this to vmware_fusion but workaround for multiple providers
  # is here: https://docs.vagrantup.com/v2/providers/configuration.html
  config.vm.provider "vmware_fusion" do |vmware, override|
    override.vm.box = "precise64_fusion"
    override.vm.box_url = "http://shopify-vagrant.s3.amazonaws.com/ubuntu-12.04_vmware.box"
    vmware.memory = 1024
    vmware.cpus = 2
  end
  
  config.vm.define "luggage", primary: true do |luggage|
    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "forwarded_port", guest: 8983, host: 8983
    config.vm.provision "shell", path: "provision.sh"
  end

end
