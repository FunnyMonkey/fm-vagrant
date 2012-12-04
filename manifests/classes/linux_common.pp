class linux_common {
	exec { "apt-update":
		command     => "/usr/bin/apt-get update"
	}
}
