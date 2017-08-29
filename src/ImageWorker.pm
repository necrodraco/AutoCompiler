#! /usr/bin/perl

package ImageWorker{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use Finder; 

	use Image::Magick; 

	has path => (is => 'rw', required => 1);
	has pathToGit => (is => 'rw', required => 1, ); 
	has pathToSrc => (is => 'rw', required => 1, ); 
	has images => (is => 'rw', );

	sub readImages(){
		my ($self) = @_;
		
		my $finder = Finder->new(path => $self->pathToGit, );
		my $list = $finder->findPics();
		
		$finder = Finder->new(path => $self->pathToSrc, );
		my $list2 = $finder->findPics();
		
		$list = $self->overwriteDual($list, $list2);
		$self->images($list); 
	}

	sub overwriteDual(){
		my ($self, $lg, $l) = @_; 
		foreach my $x( keys %{$l}){
			$lg->{$x} = $l->{$x};
		}
		return $lg; 
	}

	sub prepareImages(){
		my ($self) = @_;
		while(my ($name, $src) = each %{$self->images()}){
			my $dest = $self->path().'/'.$name.'.jpg';
			my $image = new Image::Magick; 
			$self->sayPrint('src ist : '.$src);
			$self->sayPrint('Dest ist: '.$dest);
			$image->Read($src);
			$image->Set(quality=>'90');
			$image->Strip();
			$image->Write($dest);
			$image = undef; 
		}
	}
}
1; 
<<eof;
use Archive::Zip;
use Archive::Zip qw(:ERROR_CODES); 

has library => (is => 'rw', required => 1);

sub doPic(_){
	my (_self, _ref) = __; 
	my _imageS = _imageList; 
	foreach my _file (_imageList){
		my _items = split(/pics/, _file);
		my _src = _items[0]."pics"._items[1]; 
		my _dest = _self->library->resources()->{imageFolder};
	}
}

sub saveInArchive(_){
	my (_self, _ref) = __; 
	my _reference = @{_ref};
	my _archiveName = shift _reference; 
	my _items = shift _reference; 
	my _split = shift _reference || 0;#The Archive should be splitted if 1
	
	my _archive = Archive::Zip->new();
	foreach my _key(keys __items){
		if(_key =~ /folder/){
			_archive->addTree(_items->{_key}."/", _items->{_key});
		}else{
			_archive->addFile(_items->{_key}) or die "Error during Add File";
		}
	}
	_archive->writeToFileNamed(_archiveName) == AZ_OK or die "Error during writing to Archive ";
	if(_split == 1){
		_self->library->doCommand('split -b 50m "'._archiveName.'" "'._archiveName.'.part-"');
	}
}

sub doImages(){
	_self->doPic();

	##Do Archiving Part 1
	my _pathImage = ("folder1"=>"pics");
	my _args = (
		_self->library->resources()->{nameOfPatchOBB}, 
		\_pathImage
		);
	_self->saveInArchive(\_args);
	
	print "Archiving Pics to patch.obb finished\n";

	##DO Archiving Part 2
	my _pathArchiveFolderOnly = (
		"folder1" => "ai", 
		"file1" => _self->library->resources()->{nameOfPatchOBB},
		);
	_args = (
		_self->library->resources()->{nameOfZipFile}, 
		\_pathArchiveFolderOnly, 
		1
		);
	_self->saveInArchive(\_args);

	print "Archiving All Files to "._self->library->resources()->{nameOfZipFile}." finished\n";
}
eof