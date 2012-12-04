class linux_common {
	exec { "apt-update":
		command     => "/usr/bin/apt-get update"
	}

	package { make:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { postfix:
		ensure => installed,
		require => Exec['apt-update']
	}

	file { "/etc/postfix/main.cf":
		ensure => "file",
		replace => true,
		content => "myhostname = ${fqdn}
inet_interfaces = loopback-only
local_transport = error:local delivery is disabled",
		require => Package['postfix']
	}

	package { 'libxml-xpath-perl':
		ensure => installed
	}
}
