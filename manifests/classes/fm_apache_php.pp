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

}
