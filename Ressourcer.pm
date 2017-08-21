#! /usr/bin/perl

use strict; 
use warnings; 
	
package Ressourcer{
	use Data::Dumper; 

	use Moo; 
	
	has ressource => ( is => 'rw', required => 1, ); 
	has pathSource => ( is => 'ro', );

	sub readRessources(){
		my $self = shift(); 


	}
}
1; 