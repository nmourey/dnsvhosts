#!/usr/bin/perl 
## Script to creat (RIP Dennis Riche) virtual hosts and DNS records.
## Copywrite : Humdrum Computing.
## Programmer : Nathan A. Mourey II
## Great big thanks to the perl manpages and 94.9WHOM 

## Custom module.
use modules::dnsvhost;
## Getopt module.
use Getopt::Std;

## check the global vars in dnsvhost.pm.


getopt("z:");

if (!$opt_z){
	print "The doamin name passed to -z must be passed the program.\n";
	exit;
}

mk_dns($opt_z);
foreach $row (@hosts){
	mk_vhost($row, $opt_z);
}
