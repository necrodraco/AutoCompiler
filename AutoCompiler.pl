#! /usr/bin/perl

package AutoCompiler{
	use Moose; 
	use Getopt::Long; 

	use lib 'src';
	use Library; 
	use Ressourcer; 
	use GitManager; 
	use ImageWorker; 
	use Scripter;

	my $l = Library->new();
	my $sourcPath = '';

	my $all = 1; 
	my $pull = 0; 
	my $images = 0; 
	my $scripts = 0; 
	my $help = 0; 
	my $test = 0; 
	GetOptions (
			'all' => \$all, 
			'pull' => \$pull, 
			'images' => \$images, 
			'script' => \$scripts, 
			'test' => \$test, 
			'help' => \$help, 
		);

	if($help){
		print <<EOF;
-all 		= Do all -> DEFAULT
-pull 		= actualize all Sources
-image 		= Prepare and Archive Images
-script 	= Actualize the Scripts
-test 		= Parameter set to activate Output
-help 		= get these Help message
EOF
		exit(0);
	}

	my $ressourcer = Ressourcer->new( ressource => 'settings.properties');
	$ressourcer->readRessources();

	$test = 1 if($ressourcer->getTest());
	$l->sayPrint('start') if($test); 

	$l->sayPrint('finished setting Ressources') if($test);

	my $status = 0;#
	if($all || $pull){
		$l->sayPrint('Start Pulling newest Updates');

		my $gitManager = GitManager->new( 'path' => 'submodules' );
		$status = $gitManager->pull();
		$l->sayPrint('Pulling newest Updates finished');
	}
	$status = 1 if($images || $scripts);
	
	if($status){
		$l->sayPrint('Updates where found');
		if($all || $images){
			my $imageWorker = ImageWorker->new(
				'path' => $ressourcer->sourcePath().'AutoCompiler/pics', 
				'pathToGit' => $ressourcer->sourcePath().'AutoCompiler/submodules/Live-images/pics', 
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
		}
		if($all || $scripts){
			$l->sayPrint('Scripter started');
			my $scripter = Scripter->new(
				'src' => $ressourcer->sourcePath().'AutoCompiler/submodules', 
				'dest' => $ressourcer->sourcePath().$ressourcer->other()->{'pathToApkFolder'}.'/assets/script', 
			);
			$scripter->updateScripts(
					$ressourcer->sourcePath().$ressourcer->other()->{'pathToOldApkFolder'}.'/assets/script'
					#Add Manually Folders
					);
			$l->sayPrint('Scripter Finished');
		}
	}else{
		$l->sayPrint('No new Updates');
	}
	$l->sayPrint('end') if($test);

}