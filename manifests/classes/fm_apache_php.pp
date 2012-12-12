class fm_apache_php {
	include fm_mysql
	include apache

	class {'apache::mod::php':
		require => Package["php5"]
	}

	apache::loadmodule{'rewrite':}

	package { php5:
		ensure => installed,
	}
	package { php5-mysql:
		ensure => installed,
		require => Package["php5"]
	}
	package { php5-imap:
		ensure => installed,
		require => Package["php5"]
	}
	package { php5-gd:
		ensure => installed,
		require => Package["php5"]
	}
	package { php5-dev:
		ensure => installed,
		require => Package["php5"]
	}
	package { php-pear:
		ensure => installed,
		require => Package["php5"]
	}
	package { php5-curl:
		ensure => installed,
		require => Package["php5"]
	}
	package { php-apc:
		ensure => installed,
		require => Package["php5"]
	}
	package { php5-cli:
		ensure => installed,
		require => Package["php5"]
	}
	package { php5-common:
		ensure => installed,
		require => Package["php5"]
	}

	#pecl install uploadprogress
	exec { 'pecl install uploadprogress':
		command     => "/usr/bin/pecl install uploadprogress",
		require => Package['php-pear'],
		creates => '/usr/lib/php5/20090626/uploadprogress.so'
	}

	file { '/etc/php5/apache2/conf.d/uploadprogress.ini':
		ensure 	=> "present",
		content => "extension=uploadprogress.so\n",
		mode 		=> 644,
		require => Class['apache::mod::php'],
	}

	file { '/etc/php5/conf.d/apc.ini':
		ensure => "present",
		content => "apc.shm_size=\"64M\"",
		require => Package['php-apc'],
	}

	augeas { 'php_dev_config':
		context => '/files/etc/php5/apache2/php.ini/PHP',
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
		require => Package['php5'],
		notify => Exec['reload apache']
	}
}
