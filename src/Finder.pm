#! /usr/bin/perl

package Finder{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use File::Find; 

	has 'path' => ('is' => 'ro');
	
	my @foundArray;
	my $founds;

	sub clearFinder(){
		@foundArray = (); 
		$founds = ();
	}

	sub findAllNeededRepos(){
		my $repo = $File::Find::name; 
		if($repo =~ m/.git/ && !($repo =~ m/.gitignore/)){
			$repo =~ s/\/.git//g; 
			push (@foundArray, $repo); 
		}
	}

	sub findScriptFolders(){
		my $script = $File::Find::name; 
		if($script =~ m/.lua/){
			my $script2 = (split('script/', $script))[1]; 
			$founds->{$script2} = $script; 
		}
	}

	sub findCDBs(){
		my $cdb = $File::Find::name; 
		if($cdb =~ m/.cdb/){
			push (@foundArray, $cdb); 
		}
	}

	sub findImages(){
		my $image = $File::Find::name; 
		if($image =~ m/.jpg/ || $image =~ m/.png/){
			my $image2 = $image; 
			if($image2 =~ m/pics\//){
				$image2 = (split(/pics\//, $image2))[1]; 
			}elsif($image2 =~ m/field\//){
				$image2 = (split(/field\//, $image2))[1]; 
			}
			$image2 =~ s/.png//g; 
			$image2 =~ s/.jpg//g; 
			$founds->{$image2} = $image; 
		}
	}
	sub findRepos(){
		my ($self) = @_;
		find({ wanted => \&findAllNeededRepos, no_chdir=>1}, $self->path());
		return \@foundArray;
	}

	sub findPics(){
		my ($self) = @_;
		find({ wanted => \&findImages, no_chdir=>1}, $self->path());
		return $founds;
	}

	sub findScripts(){
		my ($self) = @_;
		find({ wanted => \&findScriptFolders, no_chdir=>1}, $self->path());
		return $founds; 
	}

	sub findCDB(){
		my ($self) = @_;
		find({ wanted => \&findCDBs, no_chdir=>1}, $self->path());
		return \@foundArray;
	}
}
1; 