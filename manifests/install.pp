class forgejo::install(
  String[1] $download_source,
) {
  group { $forgejo::group:
    ensure => present,
  }

  user { $forgejo::user:
    managehome => true,
    home       => $forgejo::home,
    groups     => [
      $forgejo::group,
    ],
    require    => Group[$forgejo::group],
  }

  $forgejo_dirs = [
    $forgejo::config_dir,
    "${forgejo::home}/forgejo",
  ]

  file { $forgejo_dirs:
    ensure => 'directory',
    owner  => $forgejo::user,
    group  => $forgejo::group,
    mode   => '0700',
  }

  $forgejo_binary_path = "${forgejo::home}/forgejo/forgejo"
  $tmp_forgejo_path = "/tmp/forgejo-${forgejo::version}"

  archive { $tmp_forgejo_path:
    ensure  => present,
    source  => $download_source,
    creates => $tmp_forgejo_path,
    extract => false,
    before  => File[$forgejo_binary_path],
    cleanup => false,
    notify  => Class['forgejo::service'],
  }

  file { $forgejo_binary_path:
    ensure => 'file',
    source => $tmp_forgejo_path,
    mode   => '0700',
    owner  => $forgejo::user,
    group  => $forgejo::group,
    before => File['/usr/local/bin/forgejo'],
  }

  file { '/usr/local/bin/forgejo':
    ensure => 'link',
    target => $forgejo_binary_path,
  }
}
