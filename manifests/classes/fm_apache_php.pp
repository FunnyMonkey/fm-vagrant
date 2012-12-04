class fm_apache_php {
	include fm_mysql
	include apache

	class {'apache::mod::php':
		require => Exec['apt-update']
	}

	package { php5:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { php5-mysql:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { php5-imap:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { php5-gd:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { php5-dev:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { php-pear:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { php5-curl:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { php-apc:
		ensure => installed,
		require => Exec['apt-update']
	}
	package { php5-cli:
		ensure => installed,
		require => Exec['apt-update']
	}

	#pecl install uploadprogress
	exec { 'pecl install uploadprogress':
		command     => "/usr/bin/pecl install uploadprogress",
		require => Package['php-pear'],
		creates => '/var/tmp/pecl-install-uploadprogress'
	}

	exec { 'enable uploadprogress':
		command => '/bin/echo "extension=uploadprogress.so" > /etc/php5/apache2/conf.d/uploadprogress.ini',
		require => Class['apache::mod::php'],
		creates => '/var/tmp/enable-uploadprogress'
	}

	exec { 'increase apc shm':
		command => "/bin/echo 'apc.shm_size=\"64M\"' >> /etc/php5/conf.d/apc.ini",
		require => Package['php-apc']
	}

}
