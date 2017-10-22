#! /usr/bin/perl

package AutoCompiler{
	use Moose; 
	use Getopt::Long; 

	use lib 'src';
	use Library; 
	use PrepareManager; 
	use Ressourcer; 
	use GitManager; 
	use ImageWorker;
	use Scripter;
	use Generator; 

	my $l = Library->new();
	
	my $all = 1; 
	my $apk = 0; 
	my $pull = 0; 
	my $images = 0; 
	my $scripts = 0; 
	my $build = 0; 
	my $help = 0; 
	my $test = 0;

	GetOptions (
		'all' => \$all, 
		'apk' => \$apk, 
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
-apk 		= Update the APK. Place the new Ygopro.apk in the AutoCompiler Folder and use these parameter
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

	my $fixRessourcer = Ressourcer->new( 'ressource' => 'src/fix.properties', 'app' => 0);
	$fixRessourcer->readRessources();

	my $ressourcer;
	if(-e $fixRessourcer->other()->{'settings'}){
		$ressourcer = Ressourcer->new( 'ressource' => $fixRessourcer->other()->{'settings'}, 'app' => 0);
	}else{
		$ressourcer = Ressourcer->new( 'ressource' => $fixRessourcer->other()->{'template'}, 'app' => 0);
	}
	$ressourcer->readRessources();

	$test = 1 if($ressourcer->getTest());
	$l->sayPrint('start') if($test); 

	$l->sayPrint('finished setting Ressources') if($test);

	if($apk || !(-e $ressourcer->other()->{'pathToApkFolder'})){
		$l->sayPrint('Missing Unpacked Files. Start Preparation Module');
		my $prepareManager = PrepareManager->new(
			'path' => $ressourcer->other()->{'pathToApkFolder'}, 
			'pathOld' => $ressourcer->other()->{'pathToOldApkFolder'}, 
			'apk' => 'Ygopro.apk', 
		);
		$prepareManager->prepare();
	}

	my $status = 0;#
	if($all || $pull){
		$l->sayPrint('Start Pulling newest Updates');

		my $gitManager = GitManager->new( 'path' => 'submodules' );
		$status = $gitManager->pull();
		$l->sayPrint('Pulling newest Updates finished');
	}
	$status = 1 if($images || $scripts || $build);
	
	if($status){
		$l->sayPrint('Updates where found');
		if($all || $images){
			my $imageWorker = ImageWorker->new(
				'path' => $fixRessourcer->other()->{'pics'}, 
				'pathToGit' => $ressourcer->other()->{'pathToImages'},#submodules/Live-images/pics', 
				'pathToSrc' => $fixRessourcer->other()->{'picsPatch'}, 
				'pathToMain' => $fixRessourcer->other()->{'picsMain'}, 
				'res' => $ressourcer->other()->{'patchObb'}, 
				'zipArchive' => $fixRessourcer->other()->{'zipArchive'},
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
				'src' => $fixRessourcer->other()->{'submodules'}, 
				'dest' => $ressourcer->other()->{'pathToApkFolder'}.'/assets/script', 
			);
			$scripter->updateScripts(
					$ressourcer->other()->{'pathToOldApkFolder'}.'/assets/script'
					#Add Manually Folders
					);
			$l->sayPrint('Scripter Finished');
		}
		if($all || $build){
			my $apps; 
			if(-e $fixRessourcer->other()->{'apps'}){
				$apps = Ressourcer->new( 'ressource' => $fixRessourcer->other()->{'apps'}, 'app' => 1);
			}else{
				$apps = Ressourcer->new( 'ressource' => $fixRessourcer->other()->{'app'}, 'app' => 1);
			}
			$apps->readApps();
			while(my ($fileName, $input) = each %{$apps->app()}){
				my $generator = Generator->new(
					'cdb' => {
						'path' => $input->{'path'} ? $input->{'path'} : $fixRessourcer->other()->{'cdbPath'},
						'cdbName' => 'cards.cdb', 
						'prevCdbName' => $fileName.'.cdb', 
						'replacing' => $ressourcer->other()->{'pathToApkFolder'}.'/assets/cards.cdb',
						'opt' => $input->{'opt'}, 
					}, 
					'apkFolder' => $input->{'apkFolder'}, 
					'fileName' => $fileName,
					'ressourcepath' => $fixRessourcer->other()->{'submodules'}, 
				);
				$generator->build();
			}
			
		}
	}else{
		$l->sayPrint('No new Updates');
	}
	$l->sayPrint('end') if($test);
}