#! /usr/bin/perl

package Finder{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use File::Find; 

	has path => (is => 'ro');
	my @repos = ();

	sub findAllNeededRepos(){
		my $repo = $File::Find::name; 
		if($repo =~ m/.git/ && !($repo =~ m/.gitignore/)){
			$repo =~ s/\/.git//g; 
			push (@repos, $repo); 
		}
	}
	sub findRepos(){
		my ($self, $arg) = @_;
		find({ wanted => \&findAllNeededRepos, no_chdir=>1}, $self->path());
		return \@repos;
	}
}
1; 