
$instance_name = 'metal'

file { '/root/.ssh':
    ensure => 'directory',
    group  => 'root',
    mode    => '600',
    owner  => 'root',
}

file { '/root/.ssh/authorized_keys':
    content => template('mesaides/root_authorized_keys.erb'),
    ensure  => file,
    group   => 'root',
    mode    => '600',
    owner   => 'root',
}

file { '/opt/mes-aides/update.sh':
    ensure => file,
    group  => 'root',
    mode   => '700',
    owner  => 'root',
    source => 'puppet:///modules/mesaides/update.sh',
}

service { 'ssh':
    ensure => 'running',
}

# ^[ ^]* prefix in file_line REGEXes is used to prevent matching on legitimate textual comments
file_line { '/etc/ssh/sshd_config ChallengeResponseAuthentication':
    ensure => present,
    path   => '/etc/ssh/sshd_config',
    line   => 'ChallengeResponseAuthentication no',
    match  => '^[ ^]*ChallengeResponseAuthentication',
    notify => [ Service['ssh'] ],
}

file_line { '/etc/ssh/sshd_config PasswordAuthentication':
    ensure => present,
    path   => '/etc/ssh/sshd_config',
    line   => 'PasswordAuthentication no',
    match  => '^[ ^]*PasswordAuthentication',
    notify => [ Service['ssh'] ],
}

file_line { '/etc/ssh/sshd_config UsePAM':
    ensure => present,
    path   => '/etc/ssh/sshd_config',
    line   => 'UsePAM yes',
    match  => '^[ ^]*UsePAM',
    notify => [ Service['ssh'] ],
}

include ntp

class { 'nginx': }

file { '/etc/nginx/snippets':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
}

file { "/etc/nginx/snippets/ssl_params.conf":
    content => template('mesaides/ssl_params.erb'),
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '644',
}

file { "/etc/nginx/snippets/mes-aides-static.conf":
    content => template('mesaides/mesaides_static.erb'),
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '644',
}

/*
file_line { '/etc/nginx/mime.types WOFF':
    ensure  => present,
    path    => '/etc/nginx/mime.types',
    line    => '    application/font-woff                            woff;',
    match   => 'font\/woff.*woff;$',
    require => [ Class['nginx'] ],
}

file_line { '/etc/nginx/mime.types TTF':
    ensure  => 'present',
    path    => '/etc/nginx/mime.types',
    after   => 'application\/font-woff',
    line    => '    font/ttf                                         ttf;',
    require => [ Class['nginx'] ],
}
*/
include '::mongodb::server'

class { 'nodejs':
    repo_url_suffix => '8.x',
    nodejs_package_ensure => '8.16.1-1nodesource1',
}

package { 'git': }

group { 'main':
    ensure => present,
}

user { 'main':
    ensure     => present,
    managehome => true,
    require    => [ Group['main'] ],
}

package { 'pm2':
    ensure   => 'present',
    provider => 'npm',
    require  => [ Class['nodejs'] ],
}

exec { 'install pm2 startup script':
    command     => '/usr/bin/pm2 startup upstart -u main --hp /home/main',
    cwd         => '/home/main',
    environment => ['HOME=/home/main'],
    require     => [ Class['nodejs'], Package['pm2'] ],
    user        => 'root',
}

exec { 'chown pm2 home':
     command => '/bin/chown -R main:main /home/main/.pm2',
     require => [ Exec['install pm2 startup script'] ],
}

service { 'pm2-main':
    ensure  => 'running',
    require => [ Exec['chown pm2 home'] ]
}

file { '/home/main/setup-pm2.sh':
    ensure => file,
    group  => 'main',
    mode   => '700',
    owner  => 'main',
    source => 'puppet:///modules/mesaides/setup-pm2.sh',
    require => [ User['main'] ]
}

exec { 'pm2 install pm2-logrotate':
    command     => '/home/main/setup-pm2.sh /usr/bin/pm2',
    cwd         => '/home/main/mes-aides-ui',
    environment => ['HOME=/home/main'],
    require     => [ File['/home/main/setup-pm2.sh'], Exec['chown pm2 home'] ],
    user        => 'main',
}

vcsrepo { '/home/main/mes-aides-ui':
    ensure   => latest,
    provider => git,
    require  => [ User['main'] ],
    revision => String(file('/opt/mes-aides/ui_target_revision'), "%t"),
    source   => 'https://github.com/betagouv/mes-aides-ui.git',
    user     => 'main',
    notify   => [ File['/home/main/mes-aides-ui/backend/config/production.js'] ],
}

file { '/home/main/mes-aides-ui/backend/config/production.js':
    ensure  => present, # creates a normal file if the file is missing
    replace => false,   # setting this to false allows file resources to initialize files without overwriting future changes
    owner   => 'main',
    group   => 'main',
    mode    => '644',
    source  => '/home/main/mes-aides-ui/backend/config/continuous_integration.js',
}

# Using 'make' and 'g++'
package { 'build-essential': }

# Currently required - Failure during npm ci
# mes-aides-ui > betagouv-mes-aides-api > ludwig-api > connect-mongo > mongodb > kerberos
package { 'libkrb5-dev': }

# Install libfontconfig to generate PDFs with PhantomJS
package { 'libfontconfig': }

# Install Chromium to have Puppeteer dependencies installed as well
package { 'chromium':
    ensure => 'present',
}

/*
exec { 'install node modules for mes-aides-ui':
    command     => '/usr/bin/npm ci',
    cwd         => '/home/main/mes-aides-ui',
    environment => ['HOME=/home/main', 'PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1'],
    require     => [ Class['nodejs'], User['main'], Package['chromium'] ],
    # https://docs.puppet.com/puppet/latest/types/exec.html#exec-attribute-timeout
    #  default is 300 (seconds)
    timeout     => 1800, # 30 minutes
    user        => 'main',
}
*/

exec { 'prestart mes-aides-ui':
    command     => '/usr/bin/npm run prestart',
    cwd         => '/home/main/mes-aides-ui',
    environment => ['HOME=/home/main'],
    notify      => [ Exec['startOrReload ma-web']],#, Service['openfisca'] ],
    require     => [ Class['nodejs'], Vcsrepo['/home/main/mes-aides-ui']],# Exec['install node modules for mes-aides-ui'] ],
    user        => 'main',
}

exec { 'startOrReload ma-web':
    command     => '/usr/bin/pm2 startOrReload /home/main/mes-aides-ui/pm2_config.yaml --update-env',
    cwd         => '/home/main/mes-aides-ui',
    environment => ['HOME=/home/main', 'CHROME_DEVEL_SANDBOX=/usr/local/sbin/chrome-devel-sandbox'],
    require     => [ Exec['prestart mes-aides-ui'], Exec['install pm2 startup script'] ],
    user        => 'main',
}

cron { 'refresh mes-aides stats':
    command     => '/usr/bin/node /home/main/mes-aides-ui/backend/lib/stats',
    environment => ['HOME=/home/main'],
    hour        => 2,
    minute      => 23,
    require     => Exec['prestart mes-aides-ui'],
    user        => 'main',
}

file { '/etc/nginx/conf.d/upstreams.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '644',
    source => 'puppet:///modules/mesaides/upstreams.conf',
}

::mesaides::nginx_config { 'mes-aides.gouv.fr':
    add_www_subdomain => true,
    is_default        => true,
    nginx_root        => '/home/main/mes-aides-ui',
    require           => [ Exec['startOrReload ma-web'] ],
    use_ssl           => find_file('/opt/mes-aides/use_ssl'),
    upstream_name     => 'mes_aides',
}

::mesaides::nginx_config { "${instance_name}.mes-aides.gouv.fr":
    require        => [ Exec['startOrReload ma-web'] ],
    nginx_root     => '/home/main/mes-aides-ui',
    use_ssl        => find_file("/opt/mes-aides/${instance_name}_use_ssl"),
    upstream_name  => 'mes_aides',
}

::mesaides::monitor { "monitor.${instance_name}.mes-aides.gouv.fr":
    require => Class['nodejs'],
}

::mesaides::nginx_config { 'monitor.mes-aides.gouv.fr':
    require          => ::Mesaides::Monitor["monitor.${instance_name}.mes-aides.gouv.fr"],
    upstream_name    => 'monitor',
}

::mesaides::nginx_config { 'openfisca.mes-aides.gouv.fr':
    use_ssl          => find_file("/opt/mes-aides/${instance_name}_use_ssl"),
    upstream_name    => 'openfisca',
}

package { 'python3.7': }
package { 'python3.7-dev': }
package { 'python3.7-venv': }

$venv_dir = '/home/main/venv_python3.7'

exec { 'create virtualenv':
    command => "python3.7 -m venv ${venv_dir}",
    path    => [ '/usr/local/bin', '/usr/bin', '/bin' ],
    cwd     => '/home/main/mes-aides-ui',
    user    => 'main',
    group   => 'main',
    creates => "${venv_dir}/bin/activate",
    require => [ Package['python3.7'],  Package['python3.7-dev'], Package['python3.7-venv'] ],
}

exec { 'update virtualenv pip':
    command     => "${venv_dir}/bin/pip3 install --upgrade pip",
    cwd         => '/home/main/mes-aides-ui',
    environment => ['HOME=/home/main'],
    user        => 'main',
    require     => Exec['create virtualenv'],
}

exec { 'fetch openfisca requirements':
    command     => "${venv_dir}/bin/pip3 install --upgrade -r openfisca/requirements.txt",
    cwd         => '/home/main/mes-aides-ui',
    environment => ['HOME=/home/main'],
    notify      => [ Exec['startOrReload ma-web']],#, Service['openfisca'] ],
    require     => [ Exec['update virtualenv pip'], Vcsrepo['/home/main/mes-aides-ui'] ],
    user        => 'main',
}
/*
file { '/etc/init/openfisca.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    content => template('mesaides/openfisca.conf.erb'),
}

service { 'openfisca':
    ensure     => 'running',
    hasrestart => true,
    provider   => 'upstart',
    require    => [ File['/etc/init/openfisca.conf'], User['main'] ],
    restart    => 'service openfisca reload'
}

if find_file("/opt/mes-aides/${instance_name}_use_ssl") or find_file('/opt/mes-aides/use_ssl') {
    class { ::letsencrypt:
        config => {
            email => 'contact@mes-aides.gouv.fr',
        }
    }
}

*/



