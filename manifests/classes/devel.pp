class devel {

	case $::operatingsystem {
		'Ubuntu': {
			$mail_package    = 'mailutils'
			$vim_package     = 'vim'
			$php_package     = 'php5'
			$php_xdebug      = 'php5-xdebug'
			$xhprof_so_path  = '/usr/lib/php5/20090626/xhprof.so'
			$xhprof_ini_path = '/etc/php5/apache2/conf.d/xhprof.ini'
		}
		'CentOS': {
			$mail_package    = 'mailx'
			$vim_package     = 'vim-enhanced'
			$php_package     = 'php'
			$php_xdebug      = 'php-pecl-xdebug'
			$xhprof_so_path  = '/usr/lib64/php/modules/xhprof.so'
			$xhprof_ini_path = '/etc/php.d/xhprof.ini'
		}
	}

	package { screen:
		ensure => installed,
	}
	package { "${mail_package}":
		ensure => installed,
	}
	package { "${vim_package}":
		ensure => installed,
	}
	package { git:
		ensure => installed,
	}

	package { "${php_xdebug}":
		ensure => installed,
		require => $::operatingsystem ? {
			'Ubuntu' => Package["${php_package}"],
			'CentOS' => [ Package["${php_package}"], Yumrepo["epel"] ]
		}
	}

	# install xhprof. This requires beta install of xhprof.
	exec { 'install xhprof':
		command => '/usr/bin/pecl config-set preferred_state beta && /usr/bin/pecl install xhprof && /usr/bin/pecl config-set preferred_state stable',
		require => Package["${php_package}-common"],
		creates => "${xhprof_so_path}"
	}

	file { "${xhprof_ini_path}":
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
