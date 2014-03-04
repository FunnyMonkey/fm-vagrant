# Default hostname to the directory name
hostname = File.basename(File.dirname(__FILE__));

Vagrant::Config.run do |config|
  config.vm.host_name = hostname
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # fix "read-only filesystem" errors in Mac OS X
  # see: https://github.com/mitchellh/vagrant/issues/713
  config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/server", "1"]

  # NFS mount needs hostonly net
  # Docs: http://docs-v1.vagrantup.com/v1/docs/host_only_networking.html
  config.vm.network :hostonly, "192.168.50.4"

  # Mount webroot.
  #
  # NFS shared folders are several orders of magnitude faster, but they don't
  # work on Windows hosts, they can require a little configuration, and they
  # require that vagrant run some tasks as root. If you don't want to use NFS,
  # try enabling it here.  For more information, see:
  #
  # http://docs-v1.vagrantup.com/v1/docs/nfs.html
  #
  # To disable NFS, set :nfs => false here.
  config.vm.share_folder "www", "/var/www/%s.local" % [ hostname ], "./www", :nfs => true, :create => true

  # Forward SSH key agent over the 'vagrant ssh' connection
  config.ssh.forward_agent = true

  # Set our provisioners
  config.vm.provision :shell, :inline => "/usr/bin/apt-get update"
  config.vm.provision :shell, :inline => "/usr/bin/apt-get install -y puppet libaugeas-ruby augeas-tools rubygems"
  config.vm.provision :puppet, :module_path => "modules", :options => "--verbose" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "default.pp"
    puppet.facter = {
      "domain" => "local",
      "fqdn" => "%s.local" % [ hostname ]
    }
  end
end
