class devel {
	package { screen:
		ensure => installed,
	}
	package { mailutils:
		ensure => installed,
	}
	package { vim:
		ensure => installed,
	}
	package { vim-puppet:
		ensure => installed,
	}
	package { git:
		ensure => installed,
	}

	package {
		php5-xdebug:
		ensure => installed,
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
