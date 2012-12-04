class fm_compass {
	package { ruby-compass:
		ensure => installed,
		require => Exec['apt-update']
	}

	package { rubygems:
		ensure => installed,
		require => Exec['apt-update']
	}

	package { 'zurb-foundation':
    ensure   => 'installed',
    provider => 'gem',
	}
}
