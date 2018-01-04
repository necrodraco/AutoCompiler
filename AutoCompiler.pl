#! /usr/bin/perl

package AutoCompiler{
	use Moose; 
	use Getopt::Long; 
	use YAML 'LoadFile'; 

	use lib 'src';
	use Library; 
	use PrepareManager; 
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

	my $upload = 0; 

	GetOptions (
		'all' => \$all, 
		'apk' => \$apk, 
		'pull' => \$pull, 
		'images' => \$images, 
		'script' => \$scripts, 
		'build' => \$build, 
		'test' => \$test, 
		'h|help' => \$help, 
		#Undocumented. hidden Functions
		'upload' => \$upload, 
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
-test 		= Parameter set to activate Output
-help 		= get these Help message
EOF
		exit(0);
	}
	$all = 0 if($pull || $images || $scripts || $build || $test);

	my $fixRessourcer = LoadFile('src/fix.yaml');
	
	my $ressourcer;
	if(-e $fixRessourcer->{'settings'}){
		$ressourcer = LoadFile($fixRessourcer->{'settings'});
	}else{
		$ressourcer = LoadFile($fixRessourcer->{'template'});
	}

	$test = 1 if($ressourcer->{'testing'});
	$l->sayPrint('start') if($test); 

	$l->sayPrint('finished setting Ressources') if($test);

	if($apk || !(-e $ressourcer->{'pathToApkFolder'})){
		$l->sayPrint('Missing Unpacked Files. Start Preparation Module');
		my $prepareManager = PrepareManager->new(
			'path' => $ressourcer->{'pathToApkFolder'}, 
			'pathOld' => $ressourcer->{'pathToOldApkFolder'}, 
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
				'path' => $fixRessourcer->{'pics'}, 
				'pathToGit' => $ressourcer->{'pathToImages'},#submodules/Live-images/pics', 
				'pathToSrc' => $fixRessourcer->{'picsPatch'}, 
				'pathToMain' => $fixRessourcer->{'picsMain'}, 
				'res' => $ressourcer->{'patchObb'}, 
				'zipArchive' => $fixRessourcer->{'zipArchive'},
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
				'src' => $fixRessourcer->{'submodules'}.'/live', 
				'dest' => $ressourcer->{'pathToApkFolder'}.'/assets/script', 
			);
			$scripter->updateScripts(
					$ressourcer->{'pathToOldApkFolder'}.'/assets/script'
					#Add Manually Folders
					);
			$l->sayPrint('Scripter Finished');
		}
		if($all || $build){
			my $apps; 
			if(-e $fixRessourcer->{'apps'}){
				$apps = Ressourcer->new( 'ressource' => $fixRessourcer->{'apps'});
			}else{
				$apps = Ressourcer->new( 'ressource' => $fixRessourcer->{'app'});
			}
			$apps->readRessources();
			while(my ($fileName, $input) = each %{$apps->app()}){
				my $generator = Generator->new(
					'cdb' => {
						'path' => $input->{'path'} ? $input->{'path'} : $fixRessourcer->{'cdbPath'},
						'cdbName' => 'cards.cdb', 
						'prevCdbName' => $fileName.'.cdb', 
						'replacing' => $ressourcer->{'pathToApkFolder'}.'/assets/cards.cdb',
						'opt' => $input->{'opt'},
						'ai' => $input->{'ai'},
					}, 
					'apkFolder' => $input->{'apkFolder'}, 
					'fileName' => $fileName,
					'ressourcepath' => $fixRessourcer->{'submodules'}, 
				);
				$generator->build();
			}
			
		}
		if(-e 'src/Uploader.pm' && $upload){
			require Uploader; 
			my $uploader = Uploader->new();
			$uploader->upload();
		}
	}else{
		$l->sayPrint('No new Updates');
	}
	$l->sayPrint('end') if($test);
}