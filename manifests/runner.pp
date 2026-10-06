class forgejo::runner(
  String[1] $version,
  String[1] $download_source,
  String[1] $forgejo_uuid,
  String[1] $forgejo_token,
  String[1] $forgejo_url,
  Boolean $manage_user = true,
  String[1] $user = 'forgejo-runner',
  Boolean $manage_group = true,
  String[1] $group = 'forgejo-runner',
  Stdlib::Absolutepath $home = '/var/lib/forgejo-runner',
  Enum['binary'] $install_method = 'binary',
  Array[String] $additional_groups = [],
  String[1] $forgejo_connection_name = 'forgejo',
) {
  if $manage_group {
    group { $group:
      ensure => present,
    }
  }

  if $manage_user {
    user { $user:
      ensure     => present,
      home       => $home,
      managehome => true,
      gid        => $group,
      groups     => $additional_groups,
    }
  }

  $runner_config = {
    'server' => {
      'connections' => {
        $forgejo_connection_name => {
          'url'   => $forgejo_url,
          'uuid'  => $forgejo_uuid,
          'token' => $forgejo_token,
        }
      }
    }
  }

  case $install_method {
    'binary': {
      $forgejo_dirs = [
        "${home}/versions",
        '/etc/forgejo_runner',
      ]

      file { $forgejo_dirs:
        ensure => 'directory',
        owner  => $user,
        group  => $group,
        mode   => '0700',
      }
      $forgejo_runner_path = "${home}/versions/forgejo-runner-${version}"

      archive { $forgejo_runner_path:
        ensure  => present,
        source  => $download_source,
        creates => $forgejo_runner_path,
        extract => false,
        before  => File[$forgejo_runner_path],
        cleanup => false,
      }

      file { $forgejo_runner_path:
        ensure => 'file',
        mode   => '0700',
        owner  => $user,
        group  => $group,
        before => File['/usr/local/bin/forgejo-runner'],
      }

      file { '/usr/local/bin/forgejo-runner':
        ensure => 'link',
        target => $forgejo_runner_path,
      }

      file { '/etc/forgejo_runner/config.yml':
        ensure  => 'file',
        mode    => '0700',
        owner   => $user,
        group   => $group,
        content => stdlib::to_yaml($runner_config),
      }
    }
  }
}
