#!/bin/bash
# Vagrantfile variables
VGOPSYS='ubuntu'
VGHOSTNAME='vagrant'
VGDOMAIN='local'

# nodes.pp variables
VGUSER=`whoami`
VGPASS=\!${VGUSER}\!
VGSSHPUBKEY=`cut -d ' ' -f 2  ~/.ssh/id_rsa.pub`
VGSSHPUBKEYTYPE=`cut -d ' ' -f 1 ~/.ssh/id_rsa.pub`
VGEMAIL="${VGUSER}@${VGHOSTNAME}.${VGDOMAIN}"
VGUID=5001
VGGITCONFIG=`sed -e 's/\"/\\\"/g' ~/.gitconfig`

vgrtuid=${VGUID}
vgrtsshpubkey=${VGSSHPUBKEY}
vgrtsshpubkeytype=${VGSSHPUBKEYTYPE}
vgrtgitconfig=${VGGITCONFIG}

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
First we will ask you a few questions to identify this host and setup a default
user account to login to machine as. Defaults are enclosed in single square
brackets, pressing enter will choose the default setting.
********************************************************************************
"

read -p "operating system (centos|ubuntu) [${VGOPSYS}]: " vgrtopsys
vgrtopsys=${vgrtopsys:-$VGOPSYS}

case "${vgrtopsys}" in
    'centos' )
        vgrtboxname='centos-64-x64'
        vgrtbox_url='http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210.box'
        vgrt_shell1='if (! /bin/rpm -q rpmforge-release > /dev/null); then /bin/rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm; fi'
        vgrt_shell2='/usr/bin/yum install -y puppet ruby-augeas augeas rubygems'
        ;;
    'ubuntu' )
        vgrtboxname='precise64'
        vgrtbox_url='http://files.vagrantup.com/precise64.box'
        vgrt_shell1='/usr/bin/apt-get update'
        vgrt_shell2='/usr/bin/apt-get install -y puppet libaugeas-ruby augeas-tools rubygems'
        ;;
    * )
        echo "Sorry, '${vgrtopsys}' is not a supported operating system."
        echo 'Please hang up and try again.'
        exit
        ;;
esac

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
  config.vm.box = "${vgrtboxname}"
  config.vm.box_url = "${vgrtbox_url}"
  config.vm.provision :shell, :inline => "${vgrt_shell1}"
  config.vm.provision :shell, :inline => "${vgrt_shell2}"
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
echo "Continuing with user account questions"
echo ""

read -p "user [${VGUSER}]: " vgrtuser
vgrtuser=${vgrtuser:-$VGUSER}

read -p "email [${VGEMAIL}]: " vgrtemail
vgrtemail=${vgrtemail:-$VGEMAIL}

read -s -p "password (not echoed) [${VGPASS}]: " vgrtpass
vgrtpass=${vgrtpass:-$VGPASS}
echo

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

  group { sudo:
    ensure => present,
  }

  add_user { ${vgrtuser}:
    email    => '${vgrtemail}',
    uid      => $vgrtuid,
    password => '${vgrtpass}',
  }
  add_ssh_key { ${vgrtuser}:
    pubkey => "${vgrtsshpubkey}",
    type => "${vgrtsshpubkeytype}",
  }

  file {"/home/${vgrtuser}/.gitconfig":
    ensure  => present,
    content => "${vgrtgitconfig}",
    owner   => ${vgrtuser},
    group   => ${vgrtuser},
    mode    => 600,
    require => File["/home/${vgrtuser}"]
  }
}

EOF

echo "
********************************************************************************
You should now be ready to initialize your vagrant instance

This is done via

      vagrant up

Assuming that this did not encounter any port collisions you should be able to
ssh into using the following

      ssh USERNAME@127.0.0.1 -p 2222

********************************************************************************
"
