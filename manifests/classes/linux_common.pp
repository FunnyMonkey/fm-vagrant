class linux_common {
	Package["puppet"] -> Augeas <| |>

	case $::operatingsystem {
		'Ubuntu': {
			exec { 'apt-update':
			    command => '/usr/bin/apt-get update'
			}
			# Require apt-update for every Package command
			Exec['apt-update'] -> Package <| |>
			Package['libaugeas-ruby'] -> Augeas <| |>

			# replace puppet and ruby so we can use augeas for file config
			package { 'libaugeas-ruby':
				ensure => installed,
			}

			package { 'augeas-tools':
				ensure => installed,
			}

			package { 'libxml-xpath-perl':
				ensure => installed,
			}
		}
		'CentOS': {
			exec { 'yum-update':
			    command => '/usr/bin/yum -y update'
			}
			# Require yum-update for every Yumrepo command
			Yumrepo <| |> -> Exec['yum-update']
			Package['ruby-augeas'] -> Augeas <| |>

			include epel

			# update puppet and ruby so we can use augeas for file config
			package { 'ruby-augeas':
				ensure  => installed,
				require => Yumrepo['epel'],
			}

			package { 'augeas':
				ensure => installed,
			}

			package { 'perl-XML-XPath':
				ensure => installed,
			}

			# CentOS is more secure by default, kill that ish
			class { 'firewall':
				ensure => stopped,
			}
		}
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

	package { 'unzip':
		ensure => installed
	}

	# reload ssh
	exec {'reload ssh':
		command => $::operatingsystem ? {
			'Ubuntu' => '/etc/init.d/ssh restart',
			'CentOS' => '/etc/init.d/sshd restart',
		},
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
