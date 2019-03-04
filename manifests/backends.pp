# == Class: statsd::backends
class statsd::backends {
  $backends = join($statsd::backends, ',')
  $node_base = "${statsd::node_module_dir}/statsd/node_modules"

  # Make sure $statsd::influxdb_host is set
  if $backends =~ /influxdb/ {
    exec { 'install-statsd-influxdb-backend':
      command => "${statsd::npm_bin} install --save ${statsd::influxdb_package_name}",
      cwd     => "${statsd::node_module_dir}/statsd",
      unless  => "/usr/bin/test -d ${node_base}/statsd-influxdb-backend",
      require => Package['statsd'],
    }
  }

  # Make sure $statsd::librato_email and $statsd::librato_token are set
  if $backends =~ /librato/ {
    exec { 'install-statsd-librato-backend':
      command => "${statsd::npm_bin} install --save statsd-librato-backend",
      cwd     => "${statsd::node_module_dir}/statsd",
      unless  => "/usr/bin/test -d ${node_base}/statsd-librato-backend",
      require => Package['statsd'],
    }
  }

  # Make sure $statsd::stackdriver_apiKey is set
  if $backends =~ /stackdriver/ {
    exec { 'install-statsd-stackdriver-backend':
      command => "${statsd::npm_bin} install --save stackdriver-statsd-backend",
      cwd     => "${statsd::node_module_dir}/statsd",
      unless  => "/usr/bin/test -d ${node_base}/stackdriver-statsd-backend",
      require => Package['statsd'],
    }
  }

  # Support for newrelic backend
  if $backends =~ /newrelic/ {
    $newrelicdirs = ["${statsd::node_module_dir}/statsd", "${statsd::node_module_dir}/statsd/node_modules"]
    file { $newrelicdirs:
      ensure => directory,
    }    
    exec {'install-statsd-newrelic-backend':
      command => "${statsd::npm_bin} install --save ${statsd::node_module_dir}/statsd",
      cwd     => "${statsd::node_module_dir}/statsd/node_modules",
      unless  => "/usr/bin/test -d ${node_base}/@newrelic/statsd-infra-backend",
      notify  => Package['statsd'],
      require => File[$newrelicdirs],
    }
  }
}
