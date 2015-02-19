## Quickstart

1. Grab this code replace PROJECTNAME with the name of your project, note that this will also be the hostname of your instance and the name of the VirtualBox image if you load the VirtualBox GUI (**NOTE**: that PROJECTNAME should only contain letters, numbers, hyphens or dots. It cannot start with a hyphen or dot.)

    git clone --origin vagrant https://github.com/FunnyMonkey/fm-vagrant.git PROJECTNAME

  Note that this sets the source repo alias as 'vagrant' rather than the typical 'origin', this is intentional to avoid an accidental attempted push to this repo rather than the application repo.
2. cd into the directory the code is at:

    cd PROJECTNAME
3. run 'vagrant up' This creates the virtual machine and then kicks off puppet
configuration that will get the rest of the steps.

    vagrant up

4. Application level customizations should go into 'manifests/classes/app.pp'. You will need to edit this file before you can do much of anything. There are commented out examples for Drupal to get you started.

5. If you enabled an apache server. You can now begin working with your webserver. The webroot is NFS mounted to the virtual machine as '/var/www/192.168.33.10' and locally accessible via the 'www' directory. Visit http://192.168.33.10 for further details on web setup.



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


If the `vagrant up` hangs at `==> default: Mounting NFS shared folders...`  try issuing a `vagrant halt` from another shell and then clearing out any vagrant/virtualbox lines in /etc/exports then re-attempt `vagrant up`.

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


## Resources
[VagrantUp](http://vagrantup.com/)

[PuppetLabs](http://puppetlabs.com/)

