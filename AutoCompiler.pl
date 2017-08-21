#! /usr/bin/perl

use strict; 
use warnings; 

package AutoCompiler{
	#use feature 'say';

	use Data::Dumper; 
	use POSIX qw/strftime/;

	use Moo; 
	use Getopt::Long; 

	use src::Library; 
	use src::Ressourcer; 

	my $l = Library->new();

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

	$l->sayPrint('start') if($test); 

	$l->sayPrint('finished setting Ressources') if($test);

	$l->sayPrint('end') if($test);

}