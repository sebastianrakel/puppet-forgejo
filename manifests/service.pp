class forgejo::service(
  String[1] $database_servicename_postgresql,
) {
  $database_service = $forgejo::database_type ? {
    'postgresql' => $database_servicename_postgresql,
    default      => undef,
  }

  systemd::unit_file { 'forgejo.service':
    content => epp("${module_name}/forgejo.service.epp", {
        user             => $forgejo::user,
        group            => $forgejo::group,
        home             => $forgejo::home,
        database_service => $database_service,
    }),
  }
  ~> service { 'forgejo':
    ensure     => 'running',
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
  }
}
