class fm_mysql {
  class { '::mysql::server':
    root_password    => 'foo',
  }
}
