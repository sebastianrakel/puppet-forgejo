class forgejo::database {
  case $forgejo::database_type {
    'mysql': {
    }
    'postgresql': {
      postgresql::server::db { $forgejo::database_name:
        user     => $forgejo::database_user,
        owner    => $forgejo::database_user,
        password => postgresql_password($forgejo::database_user, $forgejo::database_password),
        require  => Class['postgresql::server'],
      }
    }
    'sqlite': {
    }
    default: {
      fail("database_type is not supported: ${forgejo::database_type}")
    }
  }
}
