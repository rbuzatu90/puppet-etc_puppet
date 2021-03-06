node 'eth0-c2-r5-u39' {
  warning("** WARNING *** ${fqdn} is puppet Mananaged by the puppetmaster -> %% moneypenny.openstack.tld %%")
  file{'/etc/hostname':
    ensure  => file,
    content => 'maas0',
  }
  file{'/etc/resolv.conf':
    ensure  => file,
    content => '# PuppetManaged
nameserver 10.21.7.1
nameserver 10.21.7.2
nameserver 10.21.7.15
search openstack.tld',
  }
  file{'/etc/network/interfaces':
    ensure => file, 
    content => '# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
        address 10.5.1.39
        netmask 255.255.255.0
        gateway 10.5.1.254
        dns-domain openstack.tld
        dns-search openstack.tld
        dns-nameservers 10.21.7.1 10.21.7.2 4.2.2.1 4.2.2.2',
  }
  file {'/etc/hosts':
    ensure => file,
    content => '#Managed by Puppet
127.0.0.1	localhost 
10.5.1.39 maas0.openstack.tld	maas0
# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters',
  }
  class{'staging':
    path   => '/root',
    owner  => 'root',
    group  => 'root',
  }
  staging::file{'postinstall':
    source => 'http://10.4.1.39/bin/postinstall',
    notify => Exec['firstboot-exec']
  }
  exec{'firstboot-exec':
    command => '/usr/bin/nohup sh -x /root/postinstall &',
    require => File['/etc/resolv.conf',
                    '/etc/network/interfaces',
                    '/etc/hosts'], 
  }
}

node 'maas0.openstack.tld' {
  warning("** WARNING *** ${fqdn} is puppet Mananaged by the puppetmaster -> %% moneypenny.openstack.tld %%")
  class{'maas':
# Uncomment to use the ppa:maas-maintainers packages
    maas_maintainers_release => 'stable',
  } -> 
  maas::superuser{ 'lis_ci_admin':
    password => 'maas',
    email    => 'nmeier@microsoft.com',
    require  => Package['maas'],
  } ->
  maas::superuser{ 'galera_admin':
    password => 'maas',
    email    => 'ppouliot@microsoft.com',
    require  => Package['maas'],
  } ->

  maas::superuser{ 'cloudbaseinit_ci_admin':
    password => 'maas',
    email    => 'ociuhandu@cloudbasesolutions.com',
    require  => Package['maas'],
  } ->

  vcsrepo{'/usr/local/src/pywinrm':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/cloudbase/pywinrm',
  }
  package{[
    'amtterm',
    'wsmancli']:
    ensure => latest,
  }

  class{'juju':}

# ->
#  juju::generic_config{'root':}
  class{'dell_openmanage::repository':}
}
node 'maas1.openstack.tld',
     'maas2.openstack.tld',
     'maas3.openstack.tld',
     'maas4.openstack.tld',
     'maas5.openstack.tld',
     'maas6.openstack.tld',
     'maas7.openstack.tld',
     'maas8.openstack.tld',
     'maas9.openstack.tld',
     'maas10.openstack.tld',
     'maas11.openstack.tld',
     'maas12.openstack.tld',
     'maas13.openstack.tld',
     'maas14.openstack.tld'{

  package{[
    'amtterm',
    'wsmancli',
    'libvirt-bin']:
    ensure => latest,
  }
  class{'maas::cluster_controller':
    cluster_region_controller => '10.5.1.39',
  }
}
