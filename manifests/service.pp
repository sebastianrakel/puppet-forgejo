class forgejo::service(
) {
  $database_service = $forgejo::database_type ? {
    'postgresql' => $forgejo::database_servicename_postgresql,
  }

  systemd::unit_file { 'forgejo.service':
    content => epp("${module_name}/forgejo.service.epp", {
        user          => $forgejo::user,
        group         => $forgejo::group,
        home          => $forgejo::home,
        database_type => $forgejo::database_type,
    }),
  }
  ~> service { 'forgejo':
    ensure     => 'running',
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
  }
}
