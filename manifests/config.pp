class forgejo::config(
  String[1] $app_name,
  String[1] $run_mode,
  String[1] $data_dir,
  String[1] $domain,
  String[1] $root_url,
  Boolean $disable_registration,
  Boolean $disable_git_hooks,
) {
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
      'APP_NAME' => $forgejo::app_name,
      'RUN_USER' => $forgejo::user,
      'RUN_MODE' => $forgejo::run_mode,
    },
    repository => {
      'ROOT' => "${forgejo::data_path}/repositories",
    },
    database   => {
      'DB_TYPE' => $forgejo_db_type,
      'HOST'    => $forgejo::database_host,
      'NAME'    => $forgejo::database_name,
      'USER'    => $forgejo::database_user,
      'PASSWD'  => $forgejo::database_password,
    },
    server     => {
      'PROTOCOL'         => $forgejo::http_protocol,
      'HTTP_ADDR'        => $forgejo::http_addr,
      'HTTP_PORT'        => $forgejo::http_port,
      'DOMAIN'           => $forgejo::domain,
      'ROOT_URL'         => $forgejo::root_url,
    },
    service => {
      'DISABLE_REGISTRATION' => $forgejo::disable_registration,
    },
    security => {
      'DISABLE_GIT_HOOKS' => $forgejo::disable_git_hooks,
    },
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
