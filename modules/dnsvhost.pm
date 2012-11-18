#!/usr/bin/perl 
## Script to creat (RIP Dennis Riche) virtual hosts and DNS records.
## Copywrite 2012 GPLv2, Humdrum Computing.
## Programmer : Nathan A. Mourey II

## A Gotcha that bit me : Not using local variables in subrutines..  use your my's  :-{)

## Include the DBD database driver for MySQL
use DBI;
use modules::config;


## SQL Statements.
$sql_insert  = "INSERT INTO " . $table . " (hostname, ip_address, subnet, domain, host_comment) VALUES (?, ?, ?, ?, ?)";
$sql_check = "SELECT id, hostname, ip_address, subnet, domain FROM " . $table . " WHERE hostname = ? AND domain = ?";
$sql_list = "SELECT id, hostname, ip_address, subnet, domain, host_comment FROM " . $table . " WHERE domain = ?";
$sql_delete = "DELETE FROM " . $table . " WHERE hostname = ? AND domain = ?";

## The Data Source Name:
$dsn = "DBI:mysql:$db;host=$host;port=$port";

## Connect to the mysql databases.
sub db_connection {
	## configure the connection not to auto commit, allowing rollbacks.
	## thanks for the execllent man pages.
	return $dbh = DBI->connect($dsn, $user, $pass, {
		PrintError => 0,
		AutoCommit => 0
	}) || die "Unable to connect to database: " . $dbh->errstr;
}

## subrutine to check if a name is in the database.
## returns the id of the name if is in the database and 0 if the name is not.
sub check_name {
	my($hostname, $zone) = @_;
	if ($DEBUG) {
		print "check_name : $hostname\n";
	}
	## Connect to the database with db_connection() subrutine from above.
	my $dbh = db_connection();
	## Use the sql statment from above and prepare the sql statment for execuction.
	## Notice that this needs to be done in order for the "?" in the statement to be used.
	my $sth = $dbh->prepare($sql_check);
	## Need to bind_paramater first?  
	## execute the statment and bind the parameter to the "?"
	$sth->execute($hostname, $zone) || die "Error " . $dbh->errstr;
	## check if there are any rows returned.  if so then the host is in the database already.
	if ($sth->rows >  0){
		($id) = $sth->fetchrow_array;
		# finish transactions, if any, and disconnect.
		$sth->finish;
		$dbh->disconnect;
		return $id;
	 } else { 
		# finish transactions, if any, and disconnect.
		$sth->finish;
		$dbh->disconnect;
		return 0;
	}
} ## end check_name;




## subrutine to check if a name is in the database.
## returns the id of the name if is in the database and 0 if the name is not.
sub get_hosts {
	my($zone) = @_;
	## Array of entries.
	my @vhosts = ();
	## Connect to the database with db_connection() subrutine from above.
	my $dbh = db_connection();
	## Use the sql statment from above and prepare the sql statment for execuction.
	my $sth = $dbh->prepare($sql_list);
	## get list of hosts in the database.
	$sth->execute($zone) || die "Error " . $dbh->errstr;
	## check if there are any rows returned.
	if ($sth->rows >  0){
		# while more rows.
		while ( @row = $sth->fetchrow_array) {
			# join the data in the row into a string with ":" seprated values.
			$row = join(":", @row);
			# push $row into the @vhost array.
			push(@vhosts,$row);
		}
		# finish transactions, if any, and disconnect.
		$sth->finish;
		$dbh->disconnect;
		return @vhosts;
	 } else { 
		# finish transactions, if any, and disconnect.
		$sth->finish;
		$dbh->disconnect;
		return 0;
	}
}

## This is a subrutine to make a vhost file.
sub mk_vhost {
	my($row, $zone) = @_;
	# split row into seprate values.
	my($id, $hostname, $ip_address, $subnet, $domain, $host_comment) = split(":", $row);
	# concatenate values for substitution in vhosts.file.
	# NOTE: no my here.
	$IPADDRESS = $subnet . "." . $ip_address;
	$HOSTNAME = $hostname . "." . $domain;
	# debug
	if ($DEBUG) {
		print "I want my MTV!!\n";
		print "$IPADDRESS, $HOSNAME\n";
	}
	# execute the $conf file. This will fill in the values with the IP and HOST from
	# above.
	do $pathtovhost;
	# prepare for writting file out.
	$outfile = $outputdir . $hostname . "." . $zone . ".conf";
	open(VHOST, ">$outfile") || die "Error opeing file. " . $!;
	# write file out.
	print VHOST $VirtualHost;
	# close the VHOST file handle.
	close VHOST;
}


## This is a subrutine to make DNS zone entries.
sub mk_dns {
	my($zone) = @_;
	@hosts = &get_hosts($zone);
	## open files for writing.
	if ($#hosts > 0) {
		open(FOREWARD, ">$outputdir/forward.$zone.zone") || die "Error opening file : " . $!;
		open(REVERSE,  ">$outputdir/reverse.$zone.zone") || die "Error opening file : " . $!;
		foreach $row (@hosts){
			# split row into seprate values.
			($id, $hostname, $ip_address, $subnet, $domain, $host_comment) = split(":", $row);
			if ($zone eq $domain){
				do $pathtorz;
				do $pathtofz;
				print FOREWARD $FZone;
				print REVERSE $RZone;
			} else {
				print "Domain for zone name and domain don't match. Cowardly skipping.\n";
			}
		}
	}
}


## Inserts vhost information into the database.
## Thanks to the awesome DBI perl manual page!
sub DBInsert {
	my($file, $zone) = @_;
	@hostinfo = &ReadInFile($file);	
	chomp @hostinfo;
	## connect to the database.
	my $dbh = db_connection();
	my $sth = $dbh->prepare($sql_insert);
	eval {	
		foreach $entry (@hostinfo){
			## split the data into peiced to be inserted into the database.
			my($hostname, $ip_address, $subnet, $domain, $host_comment) = split(":", $entry);	
			if ($domain eq $zone){
				## if the name is not already in the database then go ahead and insert into the
				# database.
				$indb = check_name($hostname, $zone);
				if (!$indb){
					@bindvars = ($hostname, $ip_address, $subnet, $domain, $host_comment);
					$sth->execute(@bindvars) or die "Execute failed :" . $dbh->errstr;
				} else {
					print "$hostname: already in the database.\n";
				}
			} else {
				print "Domain for zone name and domain don't match. Cowardly skipping.\n";
			}
		}
		$dbh->commit;
	};
	## return status from the preceding 'eval' 
	# if failure then rollback the inserts into the database and 
	# warn the user that there was an error.
	if ($@) {
		warn "Insert failed because of : " . $@;
		eval {
			## rollback the transations.
			$dbh->rollback; 
			## cleanup database handle.
			$sth->finish;
			$dbh->disconnect;
			## return with failure status.
		};
		return false;
	}
	## commit the transactions.
	$sth->finish;
	$dbh->disconnect;
	return true;
}

### Delete entries from database. - Heavly copied from DBInser() above.
## After running this command, you will need to rebuild your vhosts and dns entires with
# dnsvhostgen.pl
sub DBDelete {
	my($file, $zone) = @_;
	@hosts = &ReadInFile($file);	
	$dbh = db_connection();
	my $sth = $dbh->prepare($sql_delete);
	eval {
		foreach $row (@hosts){
			($hostname) = split(":", $row);
			$sth->execute($hostname, $zone) or die "Execution failed : " . $dbh->errstr;
		}
		$dbh->commit;
	};
	if ($@){
		warn "Delete failed : " . $@;
		eval {
			## rollback the transations.
			$dbh->rollback; 
			## cleanup database handle.
			$sth->finish;
			$dbh->disconnect;
			## return with failure status.
		};
	}
	## commit the transactions.
	$sth->finish;
	#$dbh->commit;
	$dbh->disconnect;
	return true;
}

## reads input file. -- Taken from Nate.pl from my final project in CGI class.
sub ReadInFile {
	my($file_in) = @_;
	## open file for reading.
	open(DB,"<$file_in") || die  "Unable to open file: error message $!";
	### Slurp all lines from the file into @all_data;
	@all_data = <DB>;
	### Close the DB filehandle.
	close DB;
	return @all_data;
}

1;
