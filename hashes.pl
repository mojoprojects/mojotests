#!/usr/bin/perl -w

my $message_json = {
			CPUTemp => {
				date => '2016-09-29 12:12:12',
				value => 12.2
				},
			RaspiVolt => {
				date => '2016-09-29 12:12:12',
				value => 1.2000
			}
		};
		
print "$$message_json{CPUTemp}{value}\n";
