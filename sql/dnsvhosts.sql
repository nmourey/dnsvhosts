DROP TABLE IF EXISTS $TABLE;
CREATE TABLE $TABLE (
	id 			int AUTO_INCREMENT,
	hostname		varchar(132),
	ip_address		varchar(132),
	subnet			varchar(132),
	domain			varchar(132),
	host_comment		varchar(512),
	PRIMARY KEY (id, ip_address)
);
