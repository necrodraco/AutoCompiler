#! /usr/bin/perl

package GitManager{
	use Moose; 
	use lib 'src'; 
	extends 'Library';
	
	use Finder; 

	has 'path' => ('is' => 'rw', 'required' => 1, );
	has 'changed' => ('is' => 'rw', 'default' => 1);
	
	sub pull(){
		my ($self, $test) = @_; 
		my $finder = Finder->new(path => $self->path, );
		my @list = @{$finder->findRepos()}; 
		foreach my $argument(@list){
			#my $status = 
			$self->doCommand("cd $argument && git pull");
		}
		return $self->changed();
	}
}
1;