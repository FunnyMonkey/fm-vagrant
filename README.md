## Quickstart

1. Grab this code replace PROJECTNAME with the name of your project, note that this will also be the hostname of your instance and the name of the VirtualBox image if you load the VirtualBox GUI:

    git clone https://github.com/FunnyMonkey/fm-vagrant.git PROJECTNAME
2. cd into the directory the code is at:

    cd PROJECTNAME
3. run 'vagrant up' This creates the virtual machine and then kicks off puppet
configuration that will get the rest of the steps.

    vagrant up
4. You can now begin working with your webserver. The webroot is NFS mounted to the virtual machine as '/var/www/PROJECTNAME.local' and locally accessible via the 'www' directory. If this directory does not already exist (via a checkout or other modification you have done) then it will be created during `vagrant up`.

## Detailed Setup (ubuntu)

The current state of this project assumes that you have the latest version of VirtualBox and vagrant. Note that virtualbox is the Oracle version and not the open source edition. There appear to be issues between the virtualbox guest additions and newer versions of the linux kernel which are present in 13.10.

Currently these are;

  * VirtualBox 4.3.10 r93012
  * vagrant: 1.5.2

For ubuntu you can set these both up with the following instructions;

### Remove existing virtualbox and vagrant;

    sudo apt-get remove virtualbox vagrant

### Setup oracle PPA and install virtualbox

Follow the [ppa setup instructions]https://www.virtualbox.org/wiki/Linux_Downloads

### Install vagrant

Get the latest [vagrant package]http://www.vagrantup.com/downloads.html

Note that using the package manager to install this will likely attempt to remove Oracle's virtualbox so instead use the following command (assuming your download was vagrant_1.5.2_x86_64.deb)

  sudo dpkg -i vagrant_1.5.2_x86_64.deb

### Setup vagrant plugins

This project assumes that you have vagrant-vbguest installed which will take care of making sure that your host OS and virtual environment virtualbox guest additions are the appropriate matching versions.

    vagrant plugin install vagrant-vbguest


### Potential Vagrant plugin isssues

If you get the following error then you need to update or re-install your vbguest plugin.

    Vagrant failed to initialize at a very early stage:

    The plugins failed to load properly. The error message given is
    shown below.

    undefined method `[]' for nil:NilClass

Update your plugins with;

    vagrant plugin update

If you find that command is unsuccessful try

    vagrant uninstall vagrant-vbguest


## Additional virtualbox configuration
This is well documented at http://vagrantup.com/v1/docs/vagrantfile.html but you should review the order precedence of the Vagrantfile. Generally speaking you will want to make a few host specific adjustments. Most importantly you will
make adjustments so that your machine has an outbound connection. This is typically done with a bridged network interface, but you may need to adjust to NAT depending on your network configuration. Note that bridged mode will generally fail on large public networks such as those found in airports and hotels. Below is what I have in ~/.vagrant.d/Vagrantfile

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      config.vm.network "forwarded_port", guest: 80, host: 8888,
        auto_correct: true

        config.vm.provider "virtualbox" do |v|
          v.customize ["modifyvm", :id, "--memory", "2048"]
          v.customize ["modifyvm", :id, "--cpus", "4"]
        end

    end



This sets the virtual machine memory to 2GB and the number of CPUs to 4. The virtual box documentaiton on VBoxManage contains more details on additional parameters that are available. Note that not all are configurable via vagrant.

### SSH Keys

Rather than propogate private keys to the virtual machine, which is a *bad* *insecure* practice, You should set up [ssh agent forwarding]https://help.github.com/articles/using-ssh-agent-forwarding instead. The vagrant box that is deployed will allow ssh key forwarding from your client so.

Adding the following to my .ssh/config works when ssh'ing via the port forward of 2222.

    Host 127.0.0.1
      ForwardAgent yes

That is, once the above is added to your .ssh/config you should be able to ssh in with the follwoing and your ssh keys will be forwarded;

    ssh USERNAME@127.0.0.1 -p 2222


Assuming that this did not encounter any port collisions the port will be 2222 however if there were port collisions you should see something like the following;

    [default] Fixed port collision for 22 => 2222. Now on port 2200.

Just adjust the port paramter to ssh to the corresponding replacement port, in the above case 2200.


## Resources
[VagrantUp]http://vagrantup.com/

[PuppetLabs]http://puppetlabs.com/

