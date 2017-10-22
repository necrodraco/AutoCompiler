#! /usr/bin/perl

package PrepareManager{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	has 'path' => ( 'is' => 'rw', );
	has 'pathOld' => ( 'is' => 'rw', );
	has 'apk' => ('is' => 'rw', );

	sub prepare(){
		my ($self) = @_;
		$self->doCommand('java -jar src/apktool.jar d -f -o '.$self->path().' '.$self->apk());
		$self->doCommand('java -jar src/apktool.jar d -f -o '.$self->pathOld().' '.$self->apk());
	}

}	
1; 