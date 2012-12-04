class drupal {
	include fm_mysql
	include fm_apache_php
	include fm_compass

	exec { '/usr/bin/pear channel-discover pear.drush.org && /usr/bin/pear install drush/drush':
		require => Package['php-pear']
	}

	exec { '/usr/bin/gem install zurb-foundation':
		require => Package['rubygems']
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
		serveradmin     => 'admin@funnymonkey.com',
		serveraliases   => ["www.${fqdn}",],
		notify => Exec['reload apache']
	}

	# Download drupal into the docroot
	# TODO: shouldn't we pin this for dev and prod?
	exec { 'download drupal':
		command => '/usr/bin/wget -O - http://updates.drupal.org/release-history/drupal/7.x| \
			/usr/bin/xpath -q -e "/project/releases/release[status=\'published\'][1]/download_link"| \
			sed \'s/<download_link>\(.*\)<\/download_link>/\1/g\'| \
			/usr/bin/wget -O /tmp/drupal-7.tgz -i -',
		require => Package['libxml-xpath-perl'],
		creates => '/var/tmp/drupal-downloaded'
	}

	exec {'unpack drupal':
		command => "/bin/tar -zxvf /tmp/drupal-7.tgz",
		require => Exec['download drupal'],
		cwd => "/var/www/",
		creates => '/var/tmp/drupal-unpacked'
	}

	exec {'rename drupal':
		command => "/bin/rm -rf ${fqdn}; /bin/mv drupal-7.* ${fqdn}",
		require => Exec['unpack drupal'],
		cwd => "/var/www/",
		creates => '/var/tmp/drupal-moved'
	}

  file { "/var/www/${fqdn}/sites/default/settings.php":
    ensure => present,
    require => Exec['rename drupal'],
    source => "/var/www/${fqdn}/sites/default/default.settings.php",
    owner  => 'www-data',
    group  => 'www-data',
    mode   => 0644,
  }

	file {"/var/www/${fqdn}/sites/default/files":
		ensure => "directory",
		require => Exec['rename drupal'],
		mode => 0622,
		group => 'www-data',
		owner => 'www-data',
	}

	# setup the crontab
	# TODO: the path for drush may be different on lucid
	cron { drupal:
		command => "/usr/bin/drush -r ${fqdn} cron >/dev/null",
		user    => root,
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
