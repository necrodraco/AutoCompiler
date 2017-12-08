#! /usr/bin/perl

package Finder{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use File::Find; 

	has 'path' => ('is' => 'ro', 'required' => 1, );
	
	my @foundArray;
	my $founds;

	sub clearFinder(){
		@foundArray = (); 
		$founds = ();
	}

	sub findAllNeededRepos(){
		my $repo = $File::Find::name; 
		if($repo =~ m/.git/ && !($repo =~ m/.gitignore/ || $repo =~ m/.gitattributes/)){
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
			$founds->{$cdb} = $cdb;
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
			$image2 =~ s/(.png|.jpg)//g; 
			$founds->{$image2} = $image; 
		}
	}
	sub findAiDeck(){
		my $deck = $File::Find::name; 
		if($deck =~ m/.ydk/# || $deck =~ m/.lua/
			){
			my $name = (split(/\//, $deck))[-1];
			$founds->{$name} = {'path' => $deck,'stat' => 0, };
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
		return $founds;
	}
	sub findAiDecks(){
		my ($self) = @_;
		find({ wanted => \&findAiDeck, no_chdir=>1}, $self->path());
		return $founds;
	}
}
1; 