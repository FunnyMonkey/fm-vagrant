## Quickstart
1. Grab this code
2. cd into the directory the code is at
3. run ./build.sh
4. Answer the questions the main parameter of note is the network interface. for
all other options the defaults should be acceptable.
5. Once that happens run vagrant up
6. If all is successful your vagrant machine should be booted and configured.

## Resources
http://vagrantup.com/
http://puppetlabs.com/

## Debugging
Notes if the vagrant box fails to book and hangs at;
    [default] Waiting for VM to boot. This can take a few minutes.

This seems to trigger randomly for me and I am unsure of the cause. Lots of
vagrant issues point to this halting as a network DHCP issue, but I have
verified that this is actually caused by the boot process halting on the GRUB
boot selection menu with no timeout. This may be an issue with the precise64.box

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
