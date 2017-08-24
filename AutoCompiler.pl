#! /usr/bin/perl

package AutoCompiler{
	use Moose; 
	use Getopt::Long; 

	use lib 'src';
	use Library; 
	use Ressourcer; 
	use GitManager; 

	my $l = Library->new();
	my $sourcPath = '';

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

	my $ressourcer = Ressourcer->new( ressource => 'settings.properties');
	$ressourcer->readRessources();

	$test = 1 if($ressourcer->getTest());
	$l->sayPrint('start') if($test); 

	$l->sayPrint('Start Pulling newest Updates');

	my $gitManager = GitManager->new( path => 'submodules' );
	$gitManager->pull();

	$l->sayPrint('Pulling newest Updates finished');

	$l->sayPrint('finished setting Ressources') if($test);

	$l->sayPrint('end') if($test);

}