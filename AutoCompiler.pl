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
	use Generator; 

	my $l = Library->new();
	
	my $all = 1; 
	my $pull = 0; 
	my $images = 0; 
	my $scripts = 0; 
	my $build = 0; 
	my $help = 0; 
	my $test = 0; 
	GetOptions (
			'all' => \$all, 
			'pull' => \$pull, 
			'images' => \$images, 
			'script' => \$scripts, 
			'build' => \$build, 
			'test' => \$test, 
			'h|help' => \$help, 
		);

	if($help){
		print <<EOF;
Usage: AutoCompiler <param>

-all 		= Do all -> DEFAULT
-pull 		= actualize all Sources
-image 		= Prepare and Archive Images
-script 	= Actualize the Scripts
-build 		= build all APK
-normal 	= Build Normal APK
-anime 		= Build Anime APK
-test 		= Parameter set to activate Output
-help 		= get these Help message
EOF
		exit(0);
	}
	$all = 0 if($pull || $images || $scripts || $build || $test);

	my $ressourcer;
	if(-e './settings.properties'){
		$ressourcer = Ressourcer->new( 'ressource' => 'settings.properties', 'app' => 0);
	}else{
		$ressourcer = Ressourcer->new( 'ressource' => 'template.properties', 'app' => 0);
	}
	$ressourcer->readRessources();

	my $sourcePath = $ressourcer->sourcePath();
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
	$status = 1 if($images || $scripts || $normal || $anime);
	
	if($status){
		$l->sayPrint('Updates where found');
		if($all || $images){
			my $imageWorker = ImageWorker->new(
				'path' => $sourcePath.'AutoCompiler/pics', 
				'pathToGit' => $ressourcer->other()->{'pathToImages'},#$sourcePath.'AutoCompiler/submodules/Live-images/pics', 
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
				'src' => $sourcePath.'AutoCompiler/submodules', 
				'dest' => $sourcePath.$ressourcer->other()->{'pathToApkFolder'}.'/assets/script', 
			);
			$scripter->updateScripts(
					$sourcePath.$ressourcer->other()->{'pathToOldApkFolder'}.'/assets/script'
					#Add Manually Folders
					);
			$l->sayPrint('Scripter Finished');
		}
		if($all || $build){
			my $apps; 
			if(-e 'apps.properties'){
				$apps = Ressourcer->new( 'ressource' => 'apps.properties', 'app' => 1);
			}else{
				$apps = Ressourcer->new( 'ressource' => 'app.properties', 'app' => 1);
			}
			$apps->readApps();
			while(my ($fileName, $input) = each %{$apps->app()}){
				my $generator = Generator->new(
					'cdb' => {
						'path' => $input->{'path'} ? $input->{'path'} : $sourcePath.$ressourcer->other()->{'cdbPath'},
						'cdbName' => 'cards.cdb', 
						'prevCdbName' => $fileName.'.cdb', 
						'replacing' => $sourcePath.$ressourcer->other()->{'pathToApkFolder'}.'/assets/cards.cdb',
						'opt' => $input->{'opt'}, 
					}, 
					'apkFolder' => $input->{'apkFolder'}, 
					'fileName' => $fileName,
					'ressourcepath' => $sourcePath.'./AutoCompiler/submodules'
				);
				$generator->build();
			}
			
		}
	}else{
		$l->sayPrint('No new Updates');
	}
	$l->sayPrint('end') if($test);
}