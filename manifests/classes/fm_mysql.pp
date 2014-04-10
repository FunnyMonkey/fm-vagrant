# Ensure a mysql server is setup with root password foo
class fm_mysql {
  class { '::mysql::server':
    root_password    => 'foo',
  }
}
