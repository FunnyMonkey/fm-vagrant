class fm_compass {
	package { 'ruby-compass':
		ensure => installed,
	}

	package { 'rubygems':
		ensure => installed,
	}

	package { 'compass':
		ensure => 'installed',
		provider => 'gem',
		require => Package['rubygems']
	}

	package { 'sass':
		ensure => 'installed',
		provider => 'gem',
		require => Package['rubygems']
	}

	package { 'chunky_png':
		ensure => 'installed',
		provider => 'gem',
		require => Package['rubygems']
	}

	package { 'fssm':
		ensure => 'installed',
		provider => 'gem',
		require => Package['rubygems']
	}

	package { 'zurb-foundation':
    ensure   => 'installed',
    provider => 'gem',
    require => Package['rubygems']
	}
}
