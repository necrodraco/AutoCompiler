#! /usr/bin/perl

package Generator{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use SqlManager;  
	use AiManager; 

	has 'cdb' 		=> ('is' => 'rw', 'required' => 1, );
	has 'apkFolder' => ('is' => 'rw', 'required' => 1, );
	has 'fileName' 	=> ('is' => 'rw', 'required' => 1, );
	has 'ressourcepath' => ('is' => 'rw', 'required' => 1, );

	sub build(){
		my ($self) = @_; 
		$self->sayPrint('Do Sql Action');
		my $sqlManager = SqlManager->new(
			'path' => $self->cdb()->{'path'}, 
			'fileName' => $self->cdb()->{'cdbName'}, 
			'prevName' => $self->cdb()->{'prevCdbName'}, 
			'replacing' => $self->cdb()->{'replacing'}, 
		);
		$sqlManager->createPrev();
		$self->doOpt($sqlManager, $self->cdb()->{'opt'});
		my $ai = AiManager->new('destination' => $self->apkFolder(), 'aioption' => $self->cdb()->{'ai'});
		$ai->doAi();
		$sqlManager->movePrev();
		$self->sayPrint('Sql File finished');
		$self->doApk($self->fileName());

	}

	sub doOpt(){
		my ($self, $sqlManager, $opt) = @_; 

		$sqlManager->doNormal($self->ressourcepath());
		if(defined($opt->{'anime'}) && $opt->{'anime'} == 1){
			$sqlManager->activateAnime(); 
		}

	}

	sub doApk(){
		my ($self, $fileName) = @_; 
		$self->doCommand('java -jar src/apktool.jar b -o '.$fileName.'.apk '.$self->apkFolder());
		$self->doCommand('apksign '.$fileName.'.apk');
		#EXPERIMENTAL Wording Added due to MR4
		$self->doCommand('mv '.$fileName.'.s.apk '.$fileName.'EXPERIMENTAL.apk');
	}
}
1; 