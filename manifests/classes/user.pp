# http://itand.me/using-puppet-to-manage-users-passwords-and-ss

define add_user ($email, $uid) {
  $username = $title

  user { $username:
    comment => "$email",
    home => "/home/$username",
    shell => "/bin/bash",
    uid => $uid,
    groups => ['sudo']
  }

  group { $username:
    gid => $uid,
    require => User[$username]
  }

  file { "/home/$username/":
    ensure => directory,
    owner => $username,
    group => $username,
    mode => 750,
    require => [User[$username], Group[$username]]
  }

  file {"/home/$username/.ssh":
    ensure => directory,
    owner => $username,
    group => $username,
    mode => 750,
    require => File["/home/$username/"]
  }

  exec { "sudo passwd $username <<EOF
!$username!
!$username!
EOF":
    path            => "/bin:/usr/bin",
    refreshonly     => true,
    subscribe       => User[$username],
    unless          => "cat /etc/shadow | grep $username| cut -f 2 -d : | grep -v '!'"
  }

  # now make sure that the ssh key authorized files is around
  file { "/home/$username/.ssh/authorized_keys":
    ensure  => present,
    owner   => $username,
    group   => $username,
    mode    => 600,
    require => File["/home/$username/"]
  }
}


define add_ssh_key( $key, $type ) {
  $username       = $title

  ssh_authorized_key{ "${username}_${key}":
    ensure  => present,
    key     => $key,
    type    => $type,
    user    => $username,
    require => File["/home/$username/.ssh/authorized_keys"]

  }

}
