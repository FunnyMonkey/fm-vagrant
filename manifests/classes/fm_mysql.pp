class fm_mysql {
	include mysql

  class { '::mysql::server':
    root_password    => 'foo',
  }
}
