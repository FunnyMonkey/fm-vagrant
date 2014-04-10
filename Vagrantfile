# -*- mode: ruby -*-
# vi: set ft=ruby :

# Default hostname to the directory name
hostname = File.basename(File.dirname(__FILE__));

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.
  config.vm.host_name = hostname

  config.vm.box = "FunnyMonkey Base (ubuntu server 13.10)"
  config.vm.box_url = "https://googledrive.com/host/0B0tNjg-35-SGWEE2R1M3RnJPd2M"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./www", "/srv/www", type: "nfs"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Don't boot with headless mode
    # vb.gui = true

    #   # Use VBoxManage to customize the VM. For example to change memory:
    # vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # shell provisioners to do necessary prep for subsequnent puppet provisioning
  config.vm.provision :shell, :inline => "/usr/bin/apt-get install -y puppet libaugeas-ruby augeas-tools rubygems"

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file FunnyMonkey Base (ubuntu server 13.10).pp in the manifests_path directory.
  #
  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "default.pp"
    puppet.module_path = "modules"
    puppet.options = "--verbose --hiera_config /vagrant/hiera.yaml"
  end
end
