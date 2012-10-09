#!/usr/bin/perl 
## Script to creat (RIP Dennis Riche) virtual hosts and DNS records.
## Copywrite : Humdrum Computing.
## Programmer : Nathan A. Mourey II
## Great big thanks to the perl manpages and 94.9WHOM 
## GPLv2

use Getopt::Std;
## custome module.
use modules::dnsvhost;

getopt("idz:");

if (!$opt_z) {
	print "The doamin name passed to -z must be the same as the one in the datafile.\n";
	print "Insert into database usage  : -z example.com -i <datafile>\n";
	print "Delete from database usage  : -z example.com -d <datafile>\n";
	exit;
}

if ( $opt_i && !$opt_d ){
	&DBInsert($opt_i, $opt_z);
} elsif ( !$opt_i && $opt_d ){
	&DBDelete($opt_d, $opt_z);
} else {
	print "The doamin name passed to -z must be the same as the one in the datafile.\n";
	print "Insert into database usage  : -z example.com -i <datafile>\n";
	print "Delete from database usage  : -z example.com -d <datafile>\n";
	exit;
}
