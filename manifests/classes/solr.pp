# this is a bit hackish, but since this is for development we just use the
# included solr app built using jetty.
class solr {

  exec { "get-solr":
    command => "wget -O /tmp/solr-4.4.0.tgz http://archive.apache.org/dist/lucene/solr/4.4.0/solr-4.4.0.tgz &&
      mkdir -p /opt/local &&
      tar -C /opt/local -xvzf /tmp/solr-4.4.0.tgz &&
      ln -s /opt/local/solr-4.4.0 /opt/local/solr",
    require => Package['daemon', 'openjdk-6-jdk'],
    creates => "/opt/local/solr/example/start.jar"
  }

  package { "daemon":
    ensure => installed,
  }

  package { "openjdk-6-jdk":
    ensure => installed
  }

  exec { "solr-startup":
    command => "sudo update-rc.d solr defaults",
    require => File['/etc/init.d/solr']
  }

  file { "/etc/init.d/solr":
    owner => "root",
    group => "root",
    mode => 755,
    source => "/tmp/vagrant-puppet/manifests/files/solr.init.d",
    require => Exec['get-solr']
  }

  service { "solr":
    ensure => running,
    require => File['/etc/init.d/solr']
  }

}
