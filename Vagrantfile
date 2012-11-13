# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # TODO: scripted provisioning
  # The following values can be changed for scripting the building out of a
  # test network or environment.  Here is a good suite of examples:
  # https://github.com/s0enke/ipcse11-vagrant-puppet-examples
  # config.vm.network
  config.vm.host_name = 'drupal-base-1'

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # This will get us a dynamic ip on the network, but we may at some point want
  # to register the hostname in DNS for the office:
  # http://www.held.org.il/blog/2011/01/make-dhcp-auto-update-dynamic-dns/
  config.vm.network :bridged, :bridge => 'eth0'
  config.vm.network :hostonly, "192.168.56.101"

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file base.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  config.vm.provision :puppet, :module_path => "modules", :options => "--verbose" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "site.pp"
    puppet.facter = { "domain" => "funnymonkey.com"}
  end

end
