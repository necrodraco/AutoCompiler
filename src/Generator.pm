#! /usr/bin/perl

package Generator{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use SqlManager;  

	has 'cdb' 		=> ('is' => 'rw', 'required' => 1, );
	has 'apkFolder' => ('is' => 'rw', 'required' => 1);
	has 'fileName' 	=> ('is' => 'rw', 'required' => 1, );

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
		$sqlManager->movePrev();
		$self->sayPrint('Sql File finished');
		$self->doApk($self->fileName());

	}

	sub doOpt(){
		my ($self, $sqlManager, $opt) = @_; 

		if($opt->[0] eq 'normal'){
			$sqlManager->doNormal($opt->[1]);
		}
		elsif($opt->[0] eq 'anime'){
			$sqlManager->doNormal($opt->[1]);
			$sqlManager->activateAnime()
		}

	}

	sub doApk(){
		my ($self, $fileName) = @_; 
		$self->doCommand('apktool b -o '.$fileName.'.apk '.$self->apkFolder());
		$self->doCommand('apksign '.$fileName.'.apk');
		$self->doCommand('mv '.$fileName.'.s.apk '.$fileName.'.apk');
	}

}
1; 