#!/bin/bash
# Vagrantfile variables
VGHOSTNAME='vagrant'
VGDOMAIN='local'

# nodes.pp variables
VGUSER=`whoami`
VGPASS=\!${VGUSER}\!
VGSSHPUBKEY=`cut -d ' ' -f 2  ~/.ssh/id_rsa.pub`
VGSSHPUBKEYTYPE=`cut -d ' ' -f 1 ~/.ssh/id_rsa.pub`
VGSSHKEY=`cat ~/.ssh/id_rsa`
VGEMAIL="${VGUSER}@${VGHOSTNAME}.${VGDOMAIN}"
VGUID=5001
VGGITCONFIG=`cat ~/.gitconfig`

# Check to make sure we will not clobber an existing vm config.
if [ -e Vagrantfile ]
  then
    echo "Vagrantfile exists"
    echo "If you want a new environment first run vagrant destroy to ensure everything is cleaned up."
    echo ""
    echo "Then run ./clean.sh to clean everything out."
    echo ""
    echo "** THE ABOVE STEPS WILL DELETE EVERYTHING SO MAKE SURE ALL WORK IS COMMITTED AND PUSHED **"
    exit
fi

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

read -p "email [${VGEMAIL}]: " vgrtemail
vgrtemail=${vgrtemail:-$VGEMAIL}

read -s -p "password (not echoed) [${VGPASS}]: " vgrtpass
vgrtpass=${vgrtpass:-$VGPASS}
echo

read -p "uid [${VGUID}]: " vgrtuid
vgrtuid=${vgrtuid:-$VGUID}

read -p "ssh pub key [${VGSSHPUBKEY}]: " vgrtsshpubkey
vgrtsshpubkey=${vgrtsshpubkey:-$VGSSHPUBKEY}

read -p "ssh pub key type [${VGSSHPUBKEYTYPE}]: " vgrtsshpubkeytype
vgrtsshpubkeytype=${vgrtsshpubkeytype:-$VGSSHPUBKEYTYPE}

read -s -p "ssh key (not echoed) [(using key in ~/.ssh/id_rsa)]: " vgrtsshkey
vgrtsshkey=${vgrtsshkey:-$VGSSHKEY}
echo

read -p "gitconfig (not echoed) [(using ~/.gitconfig)]: " vgrtgitconfig
vgrtgitconfig=${vgrtgitconfig:-$VGGITCONFIG}

echo ""
echo "Writing manifests/nodes.pp file"
echo ""

# create the file first and restrict the settings to avoid exposing ssh keys
touch manifests/nodes.pp
chmod 600 manifests/nodes.pp

cat > manifests/nodes.pp <<EOF
node "${vgrthostname}.${vgrtdomain}" {
  include linux_common
  include drupal
  include devel

  add_user { ${vgrtuser}:
    email    => '${vgrtemail}',
    uid      => $vgrtuid,
    password => '${vgrtpass}',
  }
  add_ssh_key { ${vgrtuser}:
    pubkey => "${vgrtsshpubkey}",
    type => "${vgrtsshpubkeytype}",
    key => "${vgrtsshkey}"
  }

  file {"/home/${vgrtuser}/.gitconfig":
    ensure  => present,
    content => "${vgrtgitconfig}",
    owner   => ${vgrtuser},
    group   => ${vgrtuser},
    mode    => 600,
    require => File["/home/${vgrtuser}"]
  }

  info('##############################################')
  info("eth0 address: \$ipaddress_eth0 (local only)")
  info("eth1 address: \$ipaddress_eth1")
  info('##############################################')
}

EOF

echo "
********************************************************************************
You should now be ready to initialize your vagrant instance

This is done via

      vagrant up

Assuming the initialization process works okay you should now then be able to
use the virtual machine.

When you run vagrant up you should see some informational output of what
addresses the various network interfaces received. It should look like;

      info: Scope(Node[HOSTNAME.DOMAIN]): ##########################
      info: Scope(Node[HOSTNAME.DOMAIN]): eth0 address: 10.0.2.15 (local only)
      info: Scope(Node[HOSTNAME.DOMAIN]): eth1 address: 192.168.1.101
      info: Scope(Node[HOSTNAME.DOMAIN]): ##########################

If not you can;
      vagrant ssh
      ip a | awk '/inet /&&!/ lo/{print \$NF,\$2}'

You should then see a list of ip addresses.
********************************************************************************
"
