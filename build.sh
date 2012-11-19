#!/bin/bash

VGHOSTNAME=drupal-base-1
VGDOMAIN=funnymonkey.com
VGBOX=precise64
VGBOXURL=http://files.vagrantup.com/precise64.box
VGBRIDGEIFACE=eth0
VGUSER=`whoami`
VGSSHKEY=`cut -d ' ' -f 2  ~/.ssh/id_rsa.pub`
VGSSHKEYTYPE=`cut -d ' ' -f 1 ~/.ssh/id_rsa.pub`
VGEMAIL="${VGUSER}@funnymonkey.com"
VGUID=5001

echo "This script takes care of creating the necessary Vagrantfile and"
echo "corresponding nodes.pp file necessary to create a new vagrant instance"
echo ""
echo "First we have a few details to determine"
echo

read -p "hostname [${VGHOSTNAME}]: " vgrthostname
vgrthostname=${vgrthostname:-$VGHOSTNAME}

read -p "domain [${VGDOMAIN}]: " vgrtdomain
vgrtdomain=${vgrtdomain:-$VGDOMAIN}

read -p "box [${VGBOX}]: " vgrtbox
vgrtbox=${vgrtbox:-$VGBOX}

read -p "box URL [${VGBOXURL}]: " vgrtboxurl
vgrtboxurl=${vgrtboxurl:-$VGBOXURL}

read -p "bridged network interface [${VGBRIDGEIFACE}]: " vgrtbridgeiface
vgrtbridgeiface=${vgrtbridgeiface:-$VGBRIDGEIFACE}

echo ""
echo "Writing Vagrantfile"
echo ""

cat > Vagrantfile <<EOF
Vagrant::Config.run do |config|
  config.vm.host_name = '${vgrthostname}'
  config.vm.box = "${vgrtbox}"
  config.vm.box_url = "${vgrtboxurl}"
  config.vm.network :bridged, :bridge => '${vgrtbridgeiface}'
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
  include linux-common
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
}
EOF

echo "#########################################################################"
echo "You should now be ready to initialize the virtualbox"
echo ""
echo "This is done via 'vagrant up' after the box is running you can type"
echo "vagrant ssh to ssh as the vagrant user. You should also be able to ssh in"
echo "as the user created above but you must first determine the IP of the box"
echo ""
