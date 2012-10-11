$VirtualHost =<<VIRTHOST
<VirtualHost $HOSTNAME:80>

	## Add cgi-bin for virtual host.
	ScriptAlias /cgi-bin/ "/var/www/vhosts/$HOSTNAME/cgi-bin/"
	<Directory "/var/www/vhosts/$HOSTNAME/cgi-bin">
		AllowOverride None
		Options ExecCGI Includes Multiviews 
		Order allow,deny
		Allow from all
	</Directory>
	## Add mod_perl handeler.

	## mod_perlwork as configured. -- Need testing.
	Alias /perl "/var/www/vhosts/$HOSTNAME/perl/"
	<Directory /var/www/vhosts/$HOSTNAME/perl>
		SetHandler perl-script
		PerlResponseHandler ModPerl::Registry
		PerlOptions +ParseHeaders
		Options +ExecCGI
	</Directory>

	## Allow cgi access.
	<Directory "/var/www/vhosts/$HOSTNAME">
		Options ExecCGI Includes Multiviews
	</Directory>

	ServerAdmin webmaster\@$HOSTNAME
	DocumentRoot /var/www/vhosts/$HOSTNAME
	ServerName $HOSTNAME
	ErrorLog logs/$HOSTNAME
	CustomLog logs/$HOSTNAME
</VirtualHost>
VIRTHOST
