# http://snowulf.com/2012/04/05/puppet-quick-tip-enabling-an-apache-module/
define apache::loadmodule () {
  exec { "/usr/sbin/a2enmod $name" :
    unless => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
    notify => Service[apache2]
  }
}
