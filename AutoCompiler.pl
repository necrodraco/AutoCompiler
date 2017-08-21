#! /usr/bin/perl

use strict; 
use warnings; 
	
use Data::Dumper; 

use Moo; 
use Getopt::Long; 
use Ressourcer; 

my $all = 0; 
my $help = 0; 
my $test = 0; 
GetOptions (
		"all" => \$all, 
		"test" => \$test, 
		"help" => \$help, 
	);

if($help){
	print <<EOF;
-all = Do all -> DEFAULT
-test = Parameter set to activate Output
-help = get these Help message
EOF
	exit(0);
}

my $ressourcer = Ressourcer->new("settings.properties");

print 'start '.&getTime()."\n" if($test); 

print 'end '.&getTime()."\n" if($test);

sub  getTime(){
	use POSIX qw/strftime/;

	return strftime "%d-%m-%Y %H:%M:%S", localtime(time);
}