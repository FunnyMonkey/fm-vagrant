class fm_compass {
	package { ruby-compass:
		ensure => installed,
	}

	package { rubygems:
		ensure => installed,
	}

	package { 'zurb-foundation':
    ensure   => 'installed',
    provider => 'gem',
	}
}
