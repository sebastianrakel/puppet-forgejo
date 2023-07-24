class forgejo::config(
  String[1] $app_name,
  String[1] $run_mode,
  String[1] $data_dir,
  String[1] $domain,
  String[1] $root_url,
  String[1] $http_addr,
  String[1] $http_protocol,
  Integer $http_port,
  Boolean $disable_registration,
  Boolean $disable_git_hooks,
  Boolean $actions_enabled,
) {
  file { "${forgejo::config_dir}/app.ini":
    ensure => 'file',
    owner  => $forgejo::user,
    group  => $forgejo::group,
    mode   => '0600',
  }

  $forgejo_db_type = case $forgejo::database_type {
    'postgresql': {
      'postgres'
    }
    'sqlite': {
      'sqlite3'
    }
    default: {
      fail('database_type needs to be postgresql or sqlite')
    }
  }

  $settings = {
    'DEFAULT'    => {
      'APP_NAME' => $app_name,
      'RUN_USER' => $forgejo::user,
      'RUN_MODE' => $run_mode,
    },
    repository => {
      'ROOT' => "${data_dir}repositories",
    },
    database   => {
      'DB_TYPE' => $forgejo_db_type,
      'HOST'    => $forgejo::database_host,
      'NAME'    => $forgejo::database_name,
      'USER'    => $forgejo::database_user,
      'PASSWD'  => $forgejo::database_password,
    },
    server     => {
      'PROTOCOL'         => $http_protocol,
      'HTTP_ADDR'        => $http_addr,
      'HTTP_PORT'        => $http_port,
      'DOMAIN'           => $domain,
      'ROOT_URL'         => $root_url,
    },
    service => {
      'DISABLE_REGISTRATION' => $disable_registration,
    },
    security => {
      'DISABLE_GIT_HOOKS' => $disable_git_hooks,
    },
    actions => {
      'ENABLED' => $actions_enabled,
    }
  }

  $settings.each | String $section, Hash $pairs | {
    $pairs.each | String $key, $value | {
      ini_setting { "ini_${section}_${key}":
        ensure  => present,
        path    => "${forgejo::config_dir}/app.ini",
        section => $section,
        setting => $key,
        value   => $value,
      }
    }
  }
}
