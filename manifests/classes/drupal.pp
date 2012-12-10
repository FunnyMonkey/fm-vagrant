class drupal {
	include fm_mysql
	include fm_apache_php
	include fm_compass

	# install drush, we use this method over the ubuntu package as that requires
	# a drush self-update that prompts for a version. This method uses drush's
	# official pear channel.
	exec { 'install drush':
		command => '/usr/bin/pear channel-discover pear.drush.org && /usr/bin/pear install drush/drush',
		require => Package['php-console-table'],
		creates => '/usr/bin/drush'
	}

	package { 'php-console-table':
		ensure => installed,
		require => Package['php-pear']
	}

	# create the main web directory parent
	file { "/var/www":
		ensure => "directory"
	}

	# Create an apache virtual host
	apache::vhost { $fqdn:
		priority        => '10',
		vhost_name      => '*',
		port            => '80',
		docroot         => "/var/www/${fqdn}/",
    override        => 'All',
		serveradmin     => "admin@${fqdn}",
		serveraliases   => ["www.${fqdn}",],
		notify => Exec['reload apache']
	}

	# setup the crontab
	# TODO: the path for drush may be different on lucid
	cron { drupal:
		command => "/usr/bin/drush -r ${fqdn} cron >/dev/null",
		user    => www-data,
		minute  => 0,
		require => Exec['install drush']
	}

	# reload apache
	exec {'reload apache':
		command => "/etc/init.d/apache2 reload",
		refreshonly => true,
	}

	# update /etc/hosts file
	host { '/etc/hosts clean':
		ip => '127.0.1.1',
		name => $hostname,
		ensure => absent
	}

	# set the aliased virtual host to the first network interface. vagrant sets this
	# If you need this externally accessible ensure you have a working setup on
	# eth1 (via bridged networking and change ip to $ipaddress_eth1)
	host { '/etc/hosts drupal':
		ip => $ipaddress_eth0,
		ensure => present,
		name => $fqdn,
		host_aliases => ["www.${fqdn}", $hostname],
	}
}
