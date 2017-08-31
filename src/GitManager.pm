#! /usr/bin/perl

package GitManager{
	use Moose; 
	use lib 'src'; 
	extends 'Library';
	use Git::Repository; 
	
	use Finder; 

	has 'path' => ('is' => 'rw', 'required' => 1, );
	has 'changed' => ('is' => 'rw', 'default' => 1);
	
	sub pull(){
		my ($self, $test) = @_; 
		my $finder = Finder->new(path => $self->path, );
		my @list = @{$finder->findRepos()}; 
		foreach my $argument(@list){
			#my $repo = Git::Repository->new(git_dir => $ENV{HOME}.'/AutoCompiler/'.$argument);
			#my $status = 
			$self->doCommand("cd $argument && git pull");
			#$self->sayPrint('Status ist: '.$status);
			#exit(0);
			#my $status = $repo->run('pull');
			#if($test){
			#	$self->sayPrint($status);
			#}
			#if($status ne 'Bereits aktuell.' && $status ne 'Already up-to-date'){
			#	$self->changed(1);
			#}
		}
		return $self->changed();
	}
}
1;