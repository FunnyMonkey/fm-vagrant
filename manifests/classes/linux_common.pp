class linux_common {
	exec { "apt-update":
	    command => "/usr/bin/apt-get update"
	}
	# Require apt-update for every Package command
	Exec["apt-update"] -> Package <| |>
	Package["puppet"] -> Augeas <| |>
	Package['libaugeas-ruby'] -> Augeas <| |>

	# replace puppet and ruby so we can use augeas for file config
	package { libaugeas-ruby:
		ensure => installed,
	}

	package { augeas-tools:
		ensure => installed,
	}

	package { puppet:
		ensure => installed,
	}

	package { make:
		ensure => installed,
	}

	package { postfix:
		ensure => installed,
	}

	file { "/etc/postfix/main.cf":
		ensure => "file",
		replace => true,
		content => "myhostname = ${fqdn}
inet_interfaces = loopback-only
default_transport = error:postfix configured to not route email",
		require => Package['postfix']
	}

	package { 'libxml-xpath-perl':
		ensure => installed
	}

	package { 'unzip':
		ensure => installed
	}

	# reload ssh
	exec {'reload ssh':
		command => "/etc/init.d/ssh restart",
		refreshonly => true,
	}

	augeas { 'ssh_allow_agent_forwarding':
		context => '/files/etc/ssh/sshd_config',
		changes => [
			'set AllowAgentForwarding yes',
		],
		notify => Exec['reload ssh']
	}
}
