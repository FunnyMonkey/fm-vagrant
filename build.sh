#!/bin/bash

VGHOSTNAME='vagrant'
VGDOMAIN='local'
VGBOX='precise64'
VGBOXURL='http://files.vagrantup.com/precise64.box'
# @todo investigate if the following works on OSX
# ip a | awk '/inet /&&!/ lo/{print $NF,$2}'
VGBRIDGEIFACE='eth0'
# @todo investigate if the following works on OSX
# grep MemFree /proc/meminfo | awk '{ print int($2/1024) }'
VGMEM=1024
# @todo investigate if the following works on OSX
# cat /proc/cpuinfo | grep processor | wc -l
VGCPU=1
VGUSER=`whoami`
VGSSHKEY=`cut -d ' ' -f 2  ~/.ssh/id_rsa.pub`
VGSSHKEYTYPE=`cut -d ' ' -f 1 ~/.ssh/id_rsa.pub`
VGEMAIL="${VGUSER}@${VGHOSTNAME}.${VGDOMAIN}"
VGUID=5001
# @todo add optional port 80 forwarding?
#   config.vm.forward_port 80, 4567

echo "
********************************************************************************
The defaults are generally a decent starting point. These values can be adjusted
by editing 'Vagrantfile' or 'manifests/nodes.pp'
********************************************************************************
"

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

read -p "configured RAM (in megabytes) [${VGMEM}]: " vgrtmem
vgrtmem=${vgrtmem:-$VGMEM}

read -p "configured CPUs [${VGCPU}]: " vgrtcpu
vgrtcpu=${vgrtcpu:-$VGCPU}

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
  config.vm.customize ["modifyvm", :id, "--memory", "${vgrtmem}"]
  config.vm.customize ["modifyvm", :id, "--cpus", "${vgrtcpu}"]
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
}
EOF

chmod 600 manifests/nodes.pp

echo "
********************************************************************************
You should now be ready to initialize your vagrant instance

This is done via

      vagrant up

Assuming the initialization process works okay

      vagrant ssh

You will then be connected to the vagrant server. To obtain the IP address
the vagrant box obtained via the bridged network. You can type the
following to obtain all active IP addresses.

      ip a | awk '/inet /&&!/ lo/{print \$NF,\$2}'

********************************************************************************
"
