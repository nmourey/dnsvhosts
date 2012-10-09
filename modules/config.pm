#!/usr/bin/perl
# Paths.
## config.pm for dnsvhost.pl scripts.
#

## More vars.
### Templates.
$pathtovhost = "templates/skel.conf.pl";
$vhostTemplate = "templates/vhost.conf";
$pathtofz = "templates/fzone.pl";
$pathtorz = "templates/rzone.pl";


#### Path to outfiles.
$outputdir = "out/";


$DEBUG=0;

## change to your needs.
$db    = "nate_dnsvhost";
$host  = "localhost";
$port  = "3306";
$table = "vhostdns";

$user = "nate";
$pass = "nate";


1;
