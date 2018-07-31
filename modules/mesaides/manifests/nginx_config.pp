define mesaides::nginx_config (
    $is_default = false,
    $use_ssl = false,
    $webroot_path = '/var/www',
    $proxied_endpoint = 'http://localhost:8000',
    $nginx_template = 'mesaides/nginx_config.erb',
    $nginx_root = nil,
    $add_www_subdomain = true
) {
    include ::nginx

    file { "/etc/nginx/sites-enabled/${name}.conf":
        content => template($nginx_template),
        ensure  => file,
        group   => 'www-data',
        mode    => '600',
        notify  => Service['nginx'],
        owner   => 'www-data',
    }

    if $use_ssl {
        include mesaides::generate_custom_dhparam

        ensure_resource('file', $webroot_path, {'ensure' => 'directory' })

        letsencrypt::certonly { $name:
            cron_success_command => 'service nginx reload',
            domains              => [ $name, "www.${name}" ],
            manage_cron          => true,
            plugin               => 'webroot',
            require              => [ File[$webroot_path], File["/etc/nginx/sites-enabled/${name}.conf"], Service['nginx'] ],
            webroot_paths        => [ $webroot_path ],
        }
    }
}
