#! /usr/bin/perl

package AutoCompiler{
	use Moose; 
	use Getopt::Long; 

	use lib 'src';
	use Library; 
	use Ressourcer; 
	use GitManager; 
	use ImageWorker; 

	my $l = Library->new();
	my $sourcPath = '';

	my $all = 0; 
	my $pull = 0; 
	my $images = 0; 
	my $help = 0; 
	my $test = 0; 
	GetOptions (
			'all' => \$all, 
			'pull' => \$pull, 
			'images' => \$images, 
			'test' => \$test, 
			'help' => \$help, 
		);

	if($help){
		print <<EOF;
-all 	= Do all -> DEFAULT
-pull 	= actualize all Sources
-images = Prepare and Archive Images
-test 	= Parameter set to activate Output
-help 	= get these Help message
EOF
		exit(0);
	}

	my $ressourcer = Ressourcer->new( ressource => 'settings.properties');
	$ressourcer->readRessources();

	$test = 1 if($ressourcer->getTest());
	$l->sayPrint('start') if($test); 

	$l->sayPrint('finished setting Ressources') if($test);

	$l->sayPrint('Start Pulling newest Updates');

	my $gitManager = GitManager->new( 'path' => 'submodules' );
	my $status = 1;#$gitManager->pull();

	$l->sayPrint('Pulling newest Updates finished');
	
	if($status){
		$l->sayPrint('Updates where found');
		my $imageWorker = ImageWorker->new(
			'path' => $ressourcer->sourcePath().'/AutoCompiler/pics', 
			'pathToGit' => $ressourcer->sourcePath().'/AutoCompiler/submodules/Live-images/pics', 
			'pathToSrc' => $ressourcer->other()->{'picsPatch'}, 
			'pathToMain' => $ressourcer->other()->{'picsMain'}, 
			'res' => $ressourcer->other(), 
		);
		$l->sayPrint('Images will be prepared to create Image File');
		$imageWorker->readImages(); 
		$imageWorker->prepareImages();
		$l->sayPrint('Image Preparing finished');
		$l->sayPrint('Start creating of Image Archive File');
		$imageWorker->archiving();
		$l->sayPrint('Creating of Image Archive Finished');
	}else{
		$l->sayPrint('No new Updates');
	}
	$l->sayPrint('end') if($test);

}