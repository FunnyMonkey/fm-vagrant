# Edit this file to suit your application needs.
class app {
  /*****************************************************************************
  ** GENERIC EXAMPLES
  *****************************************************************************/

  ##############################################################################
  # Add a MySQL database and user
  ##############################################################################
  ### Setup mysql user vagrant@localhost with password 'vagrant'
  ### To generate password hashes use the following mysql query
  ###    'SELECT password('MYPASSWORD');'
  # include fm_mysql
  # mysql_user {'vagrant@localhost':
  #   ensure                    => 'present',
  #   max_connections_per_hour  => '0',
  #   max_queries_per_hour      => '0',
  #   max_updates_per_hour      => '0',
  #   max_user_connections      => '0',
  #   password_hash             => '*04E6E1273D1783DF7D57DC5479FE01CFFDFD0058',
  # }
  # mysql_database {'vagrant':
  #   ensure  => 'present',
  #   charset => 'utf8',
  # }
  # mysql_grant { 'vagrant@localhost/vagrant.*':
  #   ensure      => 'present',
  #   options     => ['GRANT'],
  #   privileges  => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
  #   table       => 'vagrant.*',
  #   user        => 'vagrant@localhost'
  # }
  /*****************************************************************************
  ** GENERIC EXAMPLES
  *****************************************************************************/

  /*****************************************************************************
  ** DRUPAL SETUP
  *****************************************************************************/
  /* Remove this line to activate Drupal config (and one below)
  # setup apache and php
  include fm_apache_php
  include php_devel

  # Add a MySQL database and user
  include fm_mysql

  mysql_user {'drupal@localhost':
    ensure                    => 'present',
    max_connections_per_hour  => '0',
    max_queries_per_hour      => '0',
    max_updates_per_hour      => '0',
    max_user_connections      => '0',
    password_hash             => '*7AFEAE5774E672996251E09B946CB3953FC67656',
  }

  mysql_database {'drupal':
    ensure  => 'present',
    charset => 'utf8',
  }

  mysql_grant { 'drupal@localhost/drupal.*':
    ensure      => 'present',
    options     => ['GRANT'],
    privileges  => ['ALL'],
    table       => 'drupal.*',
    user        => 'drupal@localhost'
  }

  exec { 'install drush':
    command => '/usr/bin/pear channel-discover pear.drush.org && /usr/bin/pear install drush/drush',
    require => Package['php-console-table'],
    creates => '/usr/bin/drush'
  }

  cron { drupal:
    command => "/usr/bin/drush -r /var/www/192.168.33.10 cron >/dev/null",
    user    => www-data,
    minute  => 0,
    require => Exec['install drush']
  }

  Remove this line to activate Drupal config */
  /*****************************************************************************
  ** END DRUPAL SETUP
  *****************************************************************************/
}
