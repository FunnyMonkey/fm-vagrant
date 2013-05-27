class golang {
	include fm_mongo
	include fm_backbone
	include fm_compass

	package { 'golang':
		ensure => installed,
	}

  package { 'git':
    ensure => installed,
  }

  package { 'bzr':
    ensure => installed,
  }
}
