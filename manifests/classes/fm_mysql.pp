class fm_mysql {
	include mysql

	class { 'mysql::server':
		config_hash => { 'root_password' => 'foo' },
	}

  # install a database setting valid db permissions
	# TODO: if we are going to be using this for building production VMs we will
	# want to tighten this up.
	mysql::db { 'drupal':
		user     => 'drupal',
		password => 'drupal',
		host     => 'localhost',
		grant    => ['ALL'],
	}
}
