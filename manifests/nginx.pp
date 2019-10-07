$instance_name = 'metal'

::mesaides::nginx_config { 'mes-aides.gouv.fr':
    add_www_subdomain => true,
    is_default        => true,
    nginx_root        => '/home/main/mes-aides-ui',
    use_ssl           => find_file('/opt/mes-aides/use_ssl'),
    upstream_name     => 'mes_aides',
}

::mesaides::nginx_config { "${instance_name}.mes-aides.gouv.fr":
    nginx_root     => '/home/main/mes-aides-ui',
    use_ssl        => find_file("/opt/mes-aides/${instance_name}_use_ssl"),
    upstream_name  => 'mes_aides',
}

::mesaides::nginx_config { 'monitor.mes-aides.gouv.fr':
    upstream_name    => 'monitor',
}

::mesaides::nginx_config { 'openfisca.mes-aides.gouv.fr':
    use_ssl          => find_file("/opt/mes-aides/${instance_name}_use_ssl"),
    upstream_name    => 'openfisca',
}
