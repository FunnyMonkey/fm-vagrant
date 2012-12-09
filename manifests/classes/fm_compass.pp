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
	}

	package { 'sass':
		ensure => 'installed',
		provider => 'gem',
	}

	package { 'chunky_png':
		ensure => 'installed',
		provider => 'gem',
	}

	package { 'fssm':
		ensure => 'installed',
		provider => 'gem',
	}

	package { 'zurb-foundation':
    ensure   => 'installed',
    provider => 'gem',
	}
}
