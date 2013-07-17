## Quickstart

1. Grab this code replace PROJECTNAME with the name of your project, note that this will also be the name of the VirtualBox image if you load the VirtualBox GUI:

    git clone git@github.com:FunnyMonkey/fm-vagrant.git PROJECTNAME
2. cd into the directory the code is at:

    cd PROJECTNAME
3. run the build script the primary things this does is to let you pick an arbitrary hostname. This is really just a convenience so that when you login to the server
the hostname is reflected. That is your prompt will be; USERNAME@HOSTNAME I find this helpful to avoid ambiguity. Additionaly the virtualbox name if you
fire up the Virtual Box GUI will reflect the hostname you chose. This process also sets up manifets/nodes.pp to match the selected hostname.

    ./build.sh
4. run 'vagrant up' This creates the virtual machine and then kicks off puppet
configuration that will get the rest of the steps.

    vagrant up
5. You can now begin working with your webserver. The webroot is setup at;

    /var/www/HOSTNAME.DOMAIN

where HOSTNAME and DOMAIN are what you provided in step 3.

## Solr

If your app needs solr, use the solr branch. This is separate because we just download the solr tarball (120MB) and then use the include jetty example app. You will need to replace the appropriate files in `/opt/local/solr/example/` with your applications required schema and conf files.

## Host specific settings
This is well documented at http://vagrantup.com/v1/docs/vagrantfile.html but you should review the order precedence of the Vagrantfile. Generally speaking you will want to make a few host specific adjustments. Most importantly you will
make adjustments so that your machine has an outbound connection. This is typically done with a bridged network interface, but you may need to adjust to NAT depending on your network configuration. Note that bridged mode will generally fail on large public networks such as those found in airports and hotels. Below is what I have in ~/.vagrant.d/Vagrantfile

    Vagrant::Config.run do |config|
      config.vm.customize ["modifyvm", :id, "--memory", "2048"]
      config.vm.customize ["modifyvm", :id, "--cpus", "4"]
      config.vm.forward_port 80, 8888
      config.vm.network :bridged, :bridge => 'eth0'
    end

This sets an active bridged network interface up over eth0 (my active interface) and then also bumps the virtual machine memory to 2GB and the number of CPUs to 4. The virtual box documentaiton on VBoxManage contains more details on
additional parameters that are available. Note that not all are configurable via vagrant.

### SSH Keys

Rather than propogate private keys to the virtual machine, which is a *bad* *insecure* practice, You should set up [ssh agent forwarding]https://help.github.com/articles/using-ssh-agent-forwarding instead. The vagrant box that is deployed will allow ssh key forwardin from your client so.

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

## Debugging
If the vagrant box fails to boot and hangs at;
    "[default] Waiting for VM to boot. This can take a few minutes."

This seems to trigger when adjusting puppet files if puppet starts but does not
successfully finish due to syntax errors or changing files during runtime it
*seems* to cause the VM to hang-up. Searching for solutions points to halting at
this stage as a network DHCP issue, but I have verified that this is actually
caused by the boot process halting on the GRUB boot selection menu with default
timeout selection.

If this happens you will need to get the machine hash stored in .vagrant it will
be something like the following
    26424ca8-1f48-4ec1-9888-12b8f69f7c7e

Once you have the machine hash then you can halt the machine.
    VBoxManage controlvm '26424ca8-1f48-4ec1-9888-12b8f69f7c7e' poweroff

Then boot the machine with a GUI console
    VBoxManage startvm '26424ca8-1f48-4ec1-9888-12b8f69f7c7e'

Once the machine is booted login, and then run;
    sudo update-grub

Then you should be able to resume managing this via vagrant in the standard
headless manner.
