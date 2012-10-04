class linux-common {
	exec { "apt-update":
		command     => "/usr/bin/apt-get update"
	}
}
