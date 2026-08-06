class forgejo (
  String[1] $version,
  String[1] $home,
  String[1] $user,
  String[1] $group,
  Hash $user_options,
  Hash $group_options,
  Enum['mysql', 'postgresql', 'sqlite'] $database_type,
  String $database_host,
  String $database_name,
  String $database_user,
  String $database_password,
  Stdlib::Absolutepath $config_dir,
  Hash[String[1], Hash[String[1], Data]] $custom_settings,
  Boolean $manage_user,
) {
  contain forgejo::install
  contain forgejo::database
  contain forgejo::config
  contain forgejo::service

  Class['forgejo::install'] -> Class['forgejo::database'] -> Class['forgejo::config'] ~> Class['forgejo::service']
}
