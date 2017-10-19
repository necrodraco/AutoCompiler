#! /usr/bin/perl

package Scripter{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use Finder; 

	has 'src' => ('is' => 'rw', 'required' => 1);
	has 'dest' => ('is' => 'rw', 'required' => 1);
	
	sub updateScripts(){
		my ($self, @prevScripts) = @_;
		my $finder = Finder->new('path' => $self->src());
		my $scripts = $finder->findScripts();
		foreach my $prevScript(@prevScripts){
			$finder = Finder->new('path' => $prevScript);
			$finder->findScripts();
		}
		
		$self->doCommand('cd '.$self->dest().' && rm *.lua');
		while(my ($name, $path) = each %{$scripts}){
			symlink($path, $self->dest().'/'.$name);
		}
	}
}
1; 