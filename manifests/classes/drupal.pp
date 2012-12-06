class drupal {
	include fm_mysql
	include fm_apache_php
	include fm_compass

	exec { '/usr/bin/pear channel-discover pear.drush.org && /usr/bin/pear install drush/drush':
		require => Package['php-pear'],
		creates => '/usr/bin/drush'
	}

	# create a directory
	file { "/var/www":
		ensure => "directory"
	}

	# Create a apache virtual host
	apache::vhost { $fqdn:
		priority        => '10',
		vhost_name      => $fqdn,
		port            => '80',
		docroot         => "/var/www/${fqdn}/",
		serveradmin     => "admin@${fqdn}",
		serveraliases   => ["www.${fqdn}",],
		notify => Exec['reload apache']
	}

	# setup the crontab
	# TODO: the path for drush may be different on lucid
	cron { drupal:
		command => "/usr/bin/drush -r ${fqdn} cron >/dev/null",
		user    => www-data,
		minute  => 0
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
	host { '/etc/hosts drupal':
		ip => $ipaddress_eth1,
		ensure => present,
		name => $fqdn,
		host_aliases => ["www.${fqdn}", $hostname],
	}
}
