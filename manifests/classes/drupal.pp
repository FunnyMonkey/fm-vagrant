class drupal {
	include apache
	include mysql
	class {'apache::mod::php':
		require => Exec['apt-update']
	}
	class { 'mysql::server':
        	config_hash => { 'root_password' => 'foo' },
		require => Exec['apt-update']
        }

	package { php5:
		ensure => installed,
		require => Exec['apt-update']
	}
	package {
		php5-mysql: ensure => installed,
		require => Exec['apt-update']
	}
	package { php5-imap:
		ensure => installed,
		require => Exec['apt-update']
	}
	package {
		php5-gd: ensure => installed,
		require => Exec['apt-update']
	}
	package {
		php5-dev: ensure => installed,
		require => Exec['apt-update']
	}
	package {
		php-pear: ensure => installed,
		require => Exec['apt-update']
	}
	package {
		php5-curl: ensure => installed,
		require => Exec['apt-update']
	}
	package { php-apc:
		ensure => installed,
		require => Exec['apt-update']
	}
	package {
		php5-cli: ensure => installed,
		require => Exec['apt-update']
	}
	package {
		make: ensure => installed,
		require => Exec['apt-update']
	}
	package { postfix: ensure => installed,
		require => Exec['apt-update']
	}

	file { "/etc/postfix/main.cf":
		ensure => "file",
		replace => true,
		content => "myhostname = ${fqdn}
inet_interfaces = loopback-only
local_transport = error:local delivery is disabled",
		require => Package['postfix']
	}

	#pecl install uploadprogress
	exec {'pecl install uploadprogress':
		command     => "/usr/bin/pecl install uploadprogress",
		require => Package['php-pear'],
		creates => '/var/tmp/pecl-install-uploadprogress'
	}

	#echo "extension=uploadprogress.so" > /etc/php5/apache2/conf.d/uploadprogress.ini
	exec {'enable uploadprogress':
		command => '/bin/echo "extension=uploadprogress.so" > /etc/php5/apache2/conf.d/uploadprogress.ini',
		require => Class['apache::mod::php'],
		creates => '/var/tmp/enable-uploadprogress'
	}

	## lucid has a deprecated comment tag in imap.ini
	if $lsbdistcodename == 'lucid' {
		exec {'enable imap comment tag':
			command => "/bin/sed -i -e 's/# configuration for php Imap module/; configuration for php Imap module/' /etc/php5/cli/conf.d/imap.ini",
			require => Package['php5-imap']
		}

		exec {'increase apc shm':
			command => "/bin/echo 'apc.shm_size=\"64M\"' >> /etc/php5/apache2/conf.d/apc.ini",
			require => Package['php-apc']
		}
	}

	else {
		exec {'increase apc shm':
			command => "/bin/echo 'apc.shm_size=\"64M\"' >> /etc/php5/conf.d/apc.ini",
			require => Package['php-apc']
		}
	}

	package { drush:
		ensure => installed
	}

	package { 'libxml-xpath-perl':
		ensure => installed
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

	# create a directory
	file { "/var/www":
		ensure => "directory"
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

	# install a database setting valid db permissions
	# TODO: if we are going to be using this for building production VMs we will
	# want to tighten this up.
	mysql::db { 'drupal':
		user     => 'drupal',
		password => 'drupal',
		host     => 'localhost',
		grant    => ['all'],
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
