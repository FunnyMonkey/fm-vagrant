#!/bin/bash
# Vagrantfile variables
VGHOSTNAME='vagrant'
VGDOMAIN='local'

# nodes.pp variables
VGUSER=`whoami`
VGPASS=\!${VGUSER}\!
VGSSHPUBKEY=`cut -d ' ' -f 2  ~/.ssh/id_rsa.pub`
VGSSHPUBKEYTYPE=`cut -d ' ' -f 1 ~/.ssh/id_rsa.pub`
VGEMAIL="${VGUSER}@${VGHOSTNAME}.${VGDOMAIN}"
VGUID=5001
VGGITCONFIG=`cat ~/.gitconfig`
VGTYPE="drupal"

vgrtuid=${VGUID}
vgrtsshpubkey=${VGSSHPUBKEY}
vgrtsshpubkeytype=${VGSSHPUBKEYTYPE}
vgrtgitconfig=${VGGITCONFIG}

# Check if a value exists in an array
# @param $1 mixed  Needle
# @param $2 array  Haystack
# @return  Success (0) if value exists, Failure (1) otherwise
# Usage: in_array "$needle" "${haystack[@]}"
# See: http://fvue.nl/wiki/Bash:_Check_if_array_element_exists
in_array() {
    local hay needle=$1
    shift
    for hay; do
        [[ $hay == $needle ]] && return 0
    done
    return 1
}

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
  config.vm.provision :shell, :inline => "/usr/bin/apt-get install -y puppet libaugeas-ruby augeas-tools rubygems"
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


read -p "vm type (drupal|golang): [$VGTYPE}]: " vgrttype
vgrttype=${vgrttype:-$VGTYPE}
echo ${vgrttype}
while [ "${vgrttype}" != "drupal" -a "${vgrttype}" != "golang" ]
do
  read -p "invalid input vm type (drupal|golang): " vgrttype
done

echo ""
echo "Writing manifests/nodes.pp file"
echo ""

# create the file first and restrict the settings to avoid exposing ssh keys
touch manifests/nodes.pp
chmod 600 manifests/nodes.pp

cat > manifests/nodes.pp <<EOF
node "${vgrthostname}.${vgrtdomain}" {
  include linux_common
  include ${vgrttype}

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
