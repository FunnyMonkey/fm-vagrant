

Notes if the vagrant box fails to book and hangs at;
  [default] Waiting for VM to boot. This can take a few minutes.

This seems to trigger randomly for me and I am unsure of the cause. Lots of
vagrant issues point to this halting as a network DHCP issue, but I have
verified that this is actually caused by the boot process halting on the GRUB
boot selection menu with no timeout. This may be an issue with the precise64.box

If this happens you will need to get the machine hash store in .vagrant it will
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
