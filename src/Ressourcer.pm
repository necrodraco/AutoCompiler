#! /usr/bin/perl

use strict; 
use warnings; 
	
package Ressourcer{
	use Moo; 
	
	use Library; 
	
	has 'ressource' => ( 'is' => 'rw', 'required' => 1, ); 
	has 'sourcePath' => ( 'is' => 'rw', );
	has 'other' => ('is' => 'rw', );

	sub readRessources(){
		my $self = shift; 

		open(my $file, '<', $self->ressource()) or die 'cant open '.$self->filename();
		my $values = ();
		while (my $row = <$file>) {
				if(!($row =~ m/#/)){
					my @items = split(/=/,$row);
					$items[1] =~ s/\n//g;
					$values->{$items[0]} = $items[1]; 
				}
			}
		close($file);

		if(defined($values->{'pathToHome'}) && $values->{'pathToHome'} ne ''){
			$self->sourcePath($values->{'pathToHome'});
		}
		$self->other($values);
	}

	sub getTest(){
		my $self = shift; 
		return $self->other()->{'testing'};
	}
}
1; 