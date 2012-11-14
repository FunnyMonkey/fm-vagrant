class devel {
	package { screen:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { mailutils:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { vim:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { vim-puppet:
		ensure => installed,
		require => Exec['apt-update']
	}

	package {
		php5-xdebug:
		ensure => installed,
		require => Exec['apt-update']
	}

	file { "/etc/network/if-up.d/logininfo":
		ensure => "file",
		replace => true,
		owner  => 'root',
    group  => 'root',
    mode   => 0755,
		content => "#!/bin/sh
if [ \"\$METHOD\" = loopback ]; then
  exit 0
fi

# only run from ifup.
if [ \"\$MODE\" != start ]; then
  exit 0
fi

ifconfig | awk -F: '/inet addr:/ {print \$2}' | grep -v \"127.0.0.1\" | awk '{ print \$1 }' > /etc/issue
echo \"\" >> /etc/issue
"
	}

}
