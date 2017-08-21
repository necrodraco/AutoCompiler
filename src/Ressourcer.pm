#! /usr/bin/perl

use strict; 
use warnings; 
	
package Ressourcer{
	use Data::Dumper; 

	use Moo; 
	
	has ressource => ( is => 'rw', required => 1, ); 
	has pathSource => ( is => 'rw', );
	has other => (is => 'rw');

	sub readRessources(){
		my $self = shift; 

		open(my $file, "<", $self->ressource()) or die "can't open ".$self->filename();
		my $values = ();
		while (my $row = <$file>) {
				if(!($row =~ "#")){
					my @items = split(/=/,$row);
					$items[1] =~ s/\n//g;
					$values->{$items[0]} = $items[1]; 
				}
			}
		close($file);

		if(defined($values->{'pathToHome'}) && $values->{'pathToHome'} ne ''){
			$self->pathSource($values->{'pathToHome'});
		}
		$self->other($values);
	}

	sub getTest(){
		my $self = shift; 
		return $self->other()->{'testing'};
	}
}
1; 