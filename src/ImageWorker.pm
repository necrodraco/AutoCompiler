#! /usr/bin/perl

package ImageWorker{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use Finder; 

	use Image::Magick; 
	use Archive::Zip;
	use Archive::Zip qw(:ERROR_CODES); 

	has 'path' => ('is' => 'rw', 'required' => 1);
	has 'pathToGit' => ('is' => 'rw', 'required' => 1, ); 
	has 'pathToSrc' => ('is' => 'rw', 'required' => 1, ); 
	has 'pathToMain' => ('is' => 'rw', 'required' => 1, );
	has 'images' => ('is' => 'rw', );
	has 'res' => ('is' => 'rw', 'required' => 1, );
	has 'zipArchive' => ('is' => 'rw', 'required' => 1, );

	sub readImages(){
		my ($self) = @_;
		
		my $finder = Finder->new('path' => $self->pathToGit(), );
		my $list = $finder->findPics();
		
		$finder = Finder->new('path' => $self->pathToSrc(), );
		$finder->findPics();
		
		$finder = Finder->new('path' => $self->pathToMain(), );
		$finder->findPics();
		$list = $self->remove($list, $self->pathToMain());
		$self->images($list); 
		$finder->clearFinder();
	}

	sub remove(){
		my ($self, $lg, $remove) = @_; 
		foreach my $x( keys %{$lg}){
			if($lg->{$x} =~ m/$remove/){
				delete $lg->{$x};
			}
		}
		return $lg; 
	}

	sub prepareImages(){
		my ($self) = @_;
		while(my ($name, $src) = each %{$self->images()}){
			my $dest = $self->path().'/'.$name.'.jpg';
			my $image = new Image::Magick; 
			$image->Read($src);
			$image->Set('quality'=>'90');
			$image->Strip();
			$image->Write($dest);
			$image = undef; 
		}
	}

	sub archiveImages(){
		my ($self, $archiveName, $args, $split) = @_;
		my $archive = Archive::Zip->new(); 
		while(my ($opt, $name) = each %{$args}){
			if(defined($opt) && $opt =~ m/folder/){
				$archive->addTree($name.'/', $name);
			}elsif(defined($opt) && $opt =~ m/file/){
				$archive->addFile($name) or die $self->sayPrint('Error during Add File');
			}
		}
		$archive->writeToFileNamed($archiveName) == AZ_OK or die 'Error during writing to Archive '; 

		if($split){
			$self->doCommand('split -b 50m "'.$archiveName.'" "'.$archiveName.'.part-"');
		}
		
	}

	sub archiving(){
		my ($self) = @_;
		my $args = {
			'folder1' => 'pics', 
		};
		$self->archiveImages($self->res(), $args);

		$args = {
			'file1' => $self->res(), 
		};
		$self->archiveImages($self->zipArchive(), $args, 1);
	}
}
1; 