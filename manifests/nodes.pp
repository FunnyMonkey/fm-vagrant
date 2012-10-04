node "drupal-base-1.funnymonkey.com" {
	include linux-common
	# web and mysql are dependencies of drupal
	include drupal
	include devel
}

#node "julio-base-1" {
	# drupal is a dependency of drupal
	#include julio
#}
