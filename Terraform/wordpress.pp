class apache {
  package { 'apache2':
    ensure => installed,
  }

  service { 'apache2':
    ensure => running,
    enable => true,
    require => Package['apache2'],
  }

  file { '/var/www/html':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
  }
}

class php {
  package { [
    'php',
    'php-mysql',
    'libapache2-mod-php',
    'php-cli',
    'php-common',
    'php-opcache'
  ]:
    ensure => installed,
  }
}

class mysql {
  package { [
    'mysql-server',
    'mysql-client',
    'mysql-common'
  ]:
    ensure => installed,
  }

  service { 'mysql':
    ensure => running,
    enable => true,
    require => Package['mysql-server'],
  }

  exec { 'create-wordpress-db':
    command => '/usr/bin/mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"',
    unless  => '/usr/bin/mysql -e "SHOW DATABASES LIKE \'wordpress\';" | grep wordpress',
    path    => ['/usr/bin', '/bin'],
    require => Service['mysql'],
  }
}

class wordpress {
  exec { 'download-wordpress':
    command => '/usr/bin/wget https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz',
    creates => '/tmp/latest.tar.gz',
    path    => ['/usr/bin', '/bin'],
  }

  exec { 'extract-wordpress':
    command => '/bin/tar -xzf /tmp/latest.tar.gz -C /var/www/html --strip-components=1',
    path    => ['/bin', '/usr/bin'],
    require => [ File['/var/www/html'], Exec['download-wordpress'] ],
  }

  exec { 'fix-permissions':
    command => '/bin/chown -R www-data:www-data /var/www/html',
    path    => ['/bin', '/usr/bin'],
    require => Exec['extract-wordpress'],
  }

  exec { 'remove-default-index':
    command => '/bin/rm -f /var/www/html/index.html',
    onlyif  => '/usr/bin/test -f /var/www/html/index.html',
    path    => ['/bin', '/usr/bin'],
  }

  exec { 'restart-apache':
    command     => '/bin/systemctl restart apache2',
    refreshonly => true,
    subscribe   => Exec['fix-permissions'],
    path        => ['/bin', '/usr/bin'],
  }
}

include apache
include php
include mysql
include wordpress
