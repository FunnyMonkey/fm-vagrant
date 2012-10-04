class devel {
	package { screen: 
		ensure => installed,
		require => Exec['apt-update']
	}
	package { mailutils: 
		ensure => installed,
		require => Exec['apt-update']
	}
	package { vim: 
		ensure => installed,
		require => Exec['apt-update']
	}
	package { vim-puppet: 
		ensure => installed,
		require => Exec['apt-update']
	}
}
