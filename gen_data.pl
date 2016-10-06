#!/usr/bin/perl -w

print "Hello World!\n";

use DBI;
use strict;
use DateTime;

my $driver   = "SQLite"; 
my $database = "mojo.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) 
                      or die $DBI::errstr;

print "Opened database successfully\n";
for my $i (10..59)
{	my $r=rand(100);
	my $stmt = qq(INSERT INTO data (date,value) VALUES("2016-09-27 00:00:$i", $r));
	$i++;
	print "$i inserted\n";
	my $sth = $dbh->prepare( $stmt );
	my $rv = $sth->execute() or die $DBI::errstr;
	if($rv < 0){
	   print $DBI::errstr;
	}
}
print "Operation done successfully\n";
$dbh->disconnect();

