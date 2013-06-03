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

	# install xhprof. This requires beta install of xhprof.
	exec { 'install xhprof':
		command => '/usr/bin/pecl config-set preferred_state beta && /usr/bin/pecl install xhprof && /usr/bin/pecl config-set preferred_state stable',
		require => Package['php5-common'],
		creates => '/usr/lib/php5/20090626/xhprof.so'
	}

	file { '/etc/php5/apache2/conf.d/xhprof.ini':
		ensure  => 'present',
		content => 'extension=xhprof.so
xhprof.output_dir=/tmp',
		mode    =>  644,
		require => [
			Class['apache::mod::php'],
			Exec['install xhprof']
		]
	}

}
