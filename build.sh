#!/bin/bash

# Vagrantfile variables
VGHOSTNAME='vagrant'
VGDOMAIN='local'

# nodes.pp variables
VGUSER=`whoami`
VGSSHKEY=`cut -d ' ' -f 2  ~/.ssh/id_rsa.pub`
VGSSHKEYTYPE=`cut -d ' ' -f 1 ~/.ssh/id_rsa.pub`
VGEMAIL="${VGUSER}@${VGHOSTNAME}.${VGDOMAIN}"
VGUID=5001

echo "
********************************************************************************
Host specific settings should be managed via a custom Vagrantfile located in the
appropriate location.

See http://vagrantup.com/v1/docs/vagrantfile.html

Generally this will be ~/vagrant.d/Vagrantfile see README.md for more details on
options you may want to set.
********************************************************************************
"

read -p "hostname [${VGHOSTNAME}]: " vgrthostname
vgrthostname=${vgrthostname:-$VGHOSTNAME}

read -p "domain [${VGDOMAIN}]: " vgrtdomain
vgrtdomain=${vgrtdomain:-$VGDOMAIN}

echo ""
echo "Writing Vagrantfile"
echo ""

cat > Vagrantfile <<EOF
Vagrant::Config.run do |config|
  config.vm.host_name = '${vgrthostname}'
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.provision :puppet, :module_path => "modules", :options => "--verbose" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "site.pp"
    puppet.facter = {
      "domain" => "${vgrtdomain}",
      "fqdn" => "${vgrthostname}.${vgrtdomain}"
    }
  end
end
EOF

echo ""
echo "Now preparing virtual box configuration"
echo ""

read -p "user [${VGUSER}]: " vgrtuser
vgrtuser=${vgrtuser:-$VGUSER}

read -p "user [${VGEMAIL}]: " vgrtemail
vgrtemail=${vgrtemail:-$VGEMAIL}

read -p "uid [${VGUID}]: " vgrtuid
vgrtuid=${vgrtuid:-$VGUID}

read -p "ssh key [${VGSSHKEY}]: " vgrtsshkey
vgrtsshkey=${vgrtsshkey:-$VGSSHKEY}

read -p "ssh key type [${VGSSHKEYTYPE}]: " vgrtsshkeytype
vgrtsshkeytype=${vgrtsshkeytype:-$VGSSHKEYTYPE}

echo ""
echo "Writing manifests/nodes.pp file"
echo ""

cat > manifests/nodes.pp <<EOF
node "${vgrthostname}.${vgrtdomain}" {
  include linux_common
  include drupal
  include devel

  add_user { ${vgrtuser}:
    email    => "${vgrtemail}",
    uid      => $vgrtuid,
  }
  add_ssh_key { ${vgrtuser}:
    key => "${vgrtsshkey}",
    type => "${vgrtsshkeytype}"
  }

  info('##########################')
  info("eth0 address: $ipaddress_eth0")
  info("eth1 address: $ipaddress_eth1")
  info('##########################')
}

EOF

chmod 600 manifests/nodes.pp

echo "
********************************************************************************
You should now be ready to initialize your vagrant instance

This is done via

      vagrant up

Assuming the initialization process works okay you should now be able to use the
virtual machine.

When you run vagrant up you should see some informational output of what
addresses the various network interfaces received. It should look like;
info: Scope(Node[HOSTNAME.DOMAIN]): ##########################
info: Scope(Node[HOSTNAME.DOMAIN]): eth0 address: 10.0.2.15
info: Scope(Node[HOSTNAME.DOMAIN]): eth1 address: 192.168.1.101
info: Scope(Node[HOSTNAME.DOMAIN]): ##########################

If not you can;
      vagrant ssh
      ip a | awk '/inet /&&!/ lo/{print $NF,$2}'

You should then see a list of ip addresses.
********************************************************************************
"
