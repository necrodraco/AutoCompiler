#! /usr/bin/perl

package Finder{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use File::Find; 

	has 'path' => ('is' => 'ro');
	
	my @repos;
	my $images;
	my $scripts;

	sub findAllNeededRepos(){
		my $repo = $File::Find::name; 
		if($repo =~ m/.git/ && !($repo =~ m/.gitignore/)){
			$repo =~ s/\/.git//g; 
			push (@repos, $repo); 
		}
	}

	sub findScriptFolders(){
		my $script = $File::Find::name; 
		if($script =~ m/.lua/){
			my $script2 = (split('script/', $script))[1]; 
			$scripts->{$script2} = $script; 
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
			$images->{$image2} = $image; 
		}
	}
	sub findRepos(){
		my ($self, $arg) = @_;
		find({ wanted => \&findAllNeededRepos, no_chdir=>1}, $self->path());
		return \@repos;
	}

	sub findPics(){
		my ($self, $arg) = @_;
		find({ wanted => \&findImages, no_chdir=>1}, $self->path());
		return $images;
	}

	sub findScripts(){
		my ($self) = @_;
		find({ wanted => \&findScriptFolders, no_chdir=>1}, $self->path());
		return $scripts; 
	}
}
1; 