class l2tp::server {

## OpenSwan Daemon Configuration
  $ipsecPackages = ["openswan", "openswan-modules-dkms"]
  
  service { ipsec:
      ensure => true,
      enable => true,
  }
  
  "/etc/ipsec.l2tp":
    content   => template("puppet-l2tp_server/openswan/ipsec.l2tp.erb"),
    mode      => 0644,
    owner     => root,
    group     => root,
    require   => Package[$ipsecPackages],
    notify    => Service[ipsec];
    
  "/etc/ipsec.l2tp.secrets":
    content   => template("puppet-l2tp_server/openswan/ipsec.l2tp.secrets.erb"),
    mode      => 0600,
    owner     => root,
    group     => root,
    require   => Package[$ipsecPackages],
    notify    => Service[ipsec];
    
  line { "ipsecconf":
    file => "/etc/ipsec.conf",
    line => "include /etc/ipsec.l2tp",
    ensure => uncomment
  }
  
  line { "ipsecsecrets":
    file => "/etc/ipsec.secrets",
    line => "include /etc/ipsec.l2tp.secrets",
    ensure => uncomment
  }

## xL2TP Daemon Configuration

  file {"/dev/ppp":
    notify    => exec["create-ppp-node"]
  }
  
  exec {"create-ppp-node":
    command   => "mknod /dev/ppp c 108 0",
    path      => "/bin",
    unless    => "/usr/bin/test -c /dev/ppp"
  }

  service { xl2tpd:
    ensure => true,
    enable => true,
  }

  "/etc/xl2tpd/xl2tpd.conf":
    content   => template("puppet-l2tp_server/xl2tpd/xl2tpd.conf.erb"),
    mode      => 0644,
    owner     => root,
    group     => root,
    require   => Package[xl2tpd],
    notify    => Service[xl2tpd];
  "/etc/ppp/options.xl2tpd":
    content   => template("puppet-l2tp_server/xl2tpd/options.xl2tpd.erb"),
    mode      => 0644,
    owner     => root,
    group     => root,
    require   => Package[xl2tpd],
    notify    => Service[xl2tpd];
    
  

## FreeRADIUS Daemon Configuration
  $radiusPackages = ["freeradius-common", "libfreeradius", "libpython2.6", 
                   "freeradius-utils", "freeradius-ldap", "radiusclient1",
                   "libradius1", "libfreeradius2", "libradiusclient-ng2",
                 ]

  service { freeradius:
      ensure => true,
      enable => true,
  }
  
  "/etc/freeradius/modules/ldap":
    content   => template("puppet-l2tp_server/freeradius/ldap.erb"),
    mode      => 0600,
    owner     => root,
    group     => root,
    require   => Package[$radiusPackages],
    notify    => Service[freeradius];
  "/etc/freeradius/clients.conf":
    content   => template("puppet-l2tp_server/freeradius/clients.conf.erb"),
    mode      => 0600,
    owner     => root,
    group     => root,
    require   => Package[$radiusPackages],
    notify    => Service[freeradius];
  "/etc/radiusclient/servers":
    content   => template("puppet-l2tp_server/radiusclient/servers.conf.erb"),
    mode      => 0600,
    owner     => root,
    group     => root,
    require   => Package[$radiusPackages],
    notify    => Service[freeradius];
    
  file { "/etc/freeradius/sites-enabled/default":
   	ensure 	=> present,
   	source	=> ["puppet:///l2tp_server/freeradius/default"],
   	notify  => Service[freeradius],
   	owner   => root, group => root, mode => 0644,
   	require => Package[$radiusPackages]
    }
  file { "/etc/freeradius/sites-enabled/inner-tunnel":
    ensure 	=> present,
    source	=> ["puppet:///l2tp_server/freeradius/inner-tunnel"],
    notify  => Service[freeradius],
    owner   => root, group => root, mode => 0644,
    require => Package[$radiusPackages]
  }
  
}

