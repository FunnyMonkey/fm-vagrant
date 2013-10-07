class fm_apache_php {
	include fm_mysql
	class {'apache':
		mpm_module => 'prefork'
	}

	include apache::mod::php

	case $::operatingsystem {
		'Ubuntu': {
			$php_package = 'php5'
			$apc_package = 'php-apc'
			$uploadprogress_so_path = '/usr/lib/php5/20090626/uploadprogress.so'
			$uploadprogress_ini_path = '/etc/php5/apache2/conf.d/uploadprogress.ini'
			$apc_ini_path = '/etc/php5/conf.d/apc.ini'
			$php_ini_path = '/etc/php5/apache2/php.ini'

			# mod_rewrite is a default module on CentOS
			apache::mod { 'rewrite': }

			# apache::mod::php installs php package on CentOS
			package { "${php_package}":
				ensure => installed,
			}
			# php-common package on CentOS includes php-curl
			package { "${php_package}-curl":
				ensure => installed,
				require => Package["${php_package}"]
			}
		}
		'CentOS': {
			$php_package = 'php'
			$apc_package = 'php-pecl-apc'
			$uploadprogress_so_path = '/usr/lib64/php/modules/uploadprogress.so'
			$uploadprogress_ini_path = '/etc/php.d/uploadprogress.ini'
			$apc_ini_path = '/etc/php.d/apc.ini'
			$php_ini_path = '/etc/php.ini'
		}
	}

	package { "${php_package}-mysql":
		ensure => installed,
		require => Package["${php_package}"]
	}
	package { "${php_package}-imap":
		ensure => installed,
		require => Package["${php_package}"]
	}
	package { "${php_package}-gd":
		ensure => installed,
		require => Package["${php_package}"]
	}
	package { $::operatingsystem ? {
			'Ubuntu' => "${php_package}-dev",
			'CentOS' => "${php_package}-devel",
		}:
		ensure => installed,
		require => Package["${php_package}"]
	}
	package { "php-pear":
		ensure => installed,
		require => Package["${php_package}"]
	}
	package { "${apc_package}":
		ensure => installed,
		require => Package["${php_package}"]
	}
	package { "${php_package}-cli":
		ensure => installed,
		require => Package["${php_package}"]
	}
	package { "${php_package}-common":
		ensure => installed,
		require => Package["${php_package}"]
	}

	#pecl install uploadprogress
	exec { 'pecl install uploadprogress':
		command     => "/usr/bin/pecl install uploadprogress",
		require => Package['php-pear'],
		creates => "${uploadprogress_so_path}",
	}

	file { "${uploadprogress_ini_path}":
		ensure  => "present",
		content => "extension=uploadprogress.so\n",
		mode    => 644,
		require => Class['apache::mod::php'],
	}

	file { "${apc_ini_path}":
		ensure  => "present",
		content => "apc.shm_size=\"64M\"",
		require => Package["${apc_package}"],
	}

	augeas { 'php_dev_config':
		context => "/files${php_ini_path}/PHP",
		changes => [
			'set memory_limit 256M',
			'set max_execution_time 60',
			'set max_input_time 90',
			'set error_reporting E_ALL | E_STRICT',
			'set display_errors On',
			'set display_startup_errors On',
			'set html_errors On',
			'set error_prepend_string <pre>',
			'set error_apend_string </pre>',
			'set post_max_size 34M',
			'set upload_max_filesize 32M',
		],
		require => Package["${php_package}"],
		notify => Exec['reload apache']
	}
}
