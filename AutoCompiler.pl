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
	my $normal = 0; 
	my $anime = 0; 
	my $help = 0; 
	my $test = 0; 
	GetOptions (
			'all' => \$all, 
			'pull' => \$pull, 
			'images' => \$images, 
			'script' => \$scripts, 
			'normal' => \$normal,
			'anime' => \$anime,  
			'test' => \$test, 
			'help' => \$help, 
		);

	if($help){
		print <<EOF;
-all 		= Do all -> DEFAULT
-pull 		= actualize all Sources
-image 		= Prepare and Archive Images
-script 	= Actualize the Scripts
-normal 	= Build Normal APK
-anime 		= Build Anime APK
-test 		= Parameter set to activate Output
-help 		= get these Help message
EOF
		exit(0);
	}
	$all = 0 if($pull || $images || $scripts || $normal || $anime || $test);
	
	my $ressourcer = Ressourcer->new( ressource => 'settings.properties');
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
		if($all || $normal){
			my $generator = Generator->new(
				'cdb' => {
						'path' => $sourcePath.$ressourcer->other()->{'cdbPath'}, 
						'cdbName' => 'cards.cdb', 
						'prevCdbName' => 'cardsPrev.cdb', 
						'replacing' => $sourcePath.$ressourcer->other()->{'pathToApkFolder'}.'/assets/cards.cdb', 
						'opt' => [
							'normal', 
							$sourcePath.'AutoCompiler/submodules', 
						]
					},
				'apkFolder' => $sourcePath.$ressourcer->other()->{'pathToApkFolder'}, 
				'fileName' => $ressourcer->other()->{'apkName'}, 
				);
			$generator->build();
		}
		if($all || $anime){
			my $cdbName = 'cards.cdb'; 
			my $path = $sourcePath.'AutoCompiler/submodules'; 
			if($all){
				$cdbName = 'cardsPrev.cdb'; 
				$path = ''; 
			}
			my $generator = Generator->new(
				'cdb' => {
						'path' => $sourcePath.$ressourcer->other()->{'cdbPath'}, 
						'cdbName' => $cdbName, 
						'prevCdbName' => 'cardsAnimePrev.cdb', 
						'replacing' => $sourcePath.$ressourcer->other()->{'pathToApkFolder'}.'/assets/cards.cdb', 
						'opt' => [
							'anime', 
							$path, 
						]
					},
				'apkFolder' => $sourcePath.$ressourcer->other()->{'pathToApkFolder'}, 
				'fileName' => $ressourcer->other()->{'apkName'}, 
				);
			$generator->build();
		}
	}else{
		$l->sayPrint('No new Updates');
	}
	$l->sayPrint('end') if($test);
}