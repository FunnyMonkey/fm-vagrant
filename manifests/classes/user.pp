# http://itand.me/using-puppet-to-manage-users-passwords-and-ss

define add_user ($email, $uid, $password) {
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

  # Set user password except if they already have a password entry
  exec { "set $username password":
    command         => "sudo passwd $username <<EOF
$password
$password
EOF",
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

define add_ssh_key( $pubkey, $type) {
  $username       = $title

  ssh_authorized_key{ "${username}_${pubkey}":
    ensure  => present,
    key     => $pubkey,
    type    => $type,
    user    => $username,
    require => File["/home/$username/.ssh/authorized_keys"]
  }
}
