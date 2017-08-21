#! /usr/bin/perl

use strict; 
use warnings; 
use feature 'say';

use Data::Dumper; 
use POSIX qw/strftime/;

use Moo; 
use Getopt::Long; 

use src::Ressourcer; 

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

my $ressourcer = Ressourcer->new( ressource => "settings.properties");
$ressourcer->readRessources();

$test = 1 if($ressourcer->getTest());

&sayPrint('start') if($test); 

&sayPrint('finished setting Ressources') if($test);

&sayPrint('end') if($test);

sub  sayPrint(){
	my $string = shift;
	my $time = strftime "%d-%m-%Y %H:%M:%S ", localtime(time);
	say $time.$string; 
}