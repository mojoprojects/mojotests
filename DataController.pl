#!/usr/bin/perl -w

use IO::Socket::INET;
use JSON::XS qw(encode_json decode_json);
use Data::Dumper;
use DBI;
use DateTime::Format::SQLite;

# auto-flush on socket
$| = 1;
 
# creating a listening socket
my $socket = new IO::Socket::INET (
    LocalHost => '0.0.0.0',
    LocalPort => '7777',
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
);
die "cannot create socket $!\n" unless $socket;
print "server waiting for client connection on port 7777\n";

while(1)
{
    my $client_socket = $socket->accept();
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    print "connection from $client_address:$client_port\n";
    my $data = "";
    $client_socket->recv($data, 1024);
    my $decoded_data = decode_json $data;
    print Dumper $decoded_data;
    $data = "ok";
    $client_socket->send($data);
    shutdown($client_socket, 1);
    
    my $driver   = "SQLite"; 
	my $database = "mojo.db";
	my $dsn = "DBI:$driver:dbname=$database";
	my $userid = "";
	my $password = "";
	my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) 
						  or die $DBI::errstr;

	print "Opened database successfully\n";
    
    my $dt = DateTime::Format::SQLite->parse_datetime( localtime(time));
	my $v = $$decoded_data{RaspiVolt}{value};
	my $stmt = qq(INSERT INTO sensordata (sensorid, dtime, value, UOM, refid) 
					VALUES(1,$dt,$v,"V",0));
	my $sth = $dbh->prepare( $stmt );
	my $rv = $sth->execute() or die $DBI::errstr;
	
	if($rv < 0){ print $DBI::errstr;}
	$v = $$decoded_data{CPUTemp}{value};
    $stmt = qq(INSERT INTO sensordata (sensorid, dtime, value, UOM, refid) 
					VALUES(2,$dt,$v,"C",0));
	$sth = $dbh->prepare( $stmt );
	$rv = $sth->execute() or die $DBI::errstr;
	if($rv < 0){ print $DBI::errstr;}
}

$dbh->disconnect();
$socket->close();
