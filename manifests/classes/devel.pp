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
	package { git:
		ensure => installed,
	}
	package {
		php5-xdebug:
		ensure => installed,
		require => Package['php5']
	}
}
