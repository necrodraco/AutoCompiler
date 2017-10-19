#! /usr/bin/perl

use strict; 
use warnings; 
	
package Ressourcer{
	use Moo; 
	
	use Library; 
	
	has 'ressource' => ( 'is' => 'rw', 'required' => 1, ); 
	has 'app' => ( 'is' => 'rw', 'required' => 1, );
	has 'other' => ('is' => 'rw', );

	sub readRessources(){
		my ($self) = @_; 
		if($self->app() == 0){
			open(my $file, '<', $self->ressource()) or die 'cant open '.$self->ressource();
			my $values = ();
			while (my $row = <$file>) {
					if(!($row =~ m/#/) && $row =~ m/=/){
						my @items = split(/=/,$row);
						$items[1] =~ s/\n//g;
						$values->{$items[0]} = $items[1]; 
					}
				}
			close($file);

			$self->other($values);
		}else{
			die "This Ressource is an App\n";
		}
	}

	sub readApps(){
		my ($self) = @_; 
		if($self->app()){
			open(my $file, '<', $self->ressource()) or die 'cant open '.$self->ressource();
			my $values = ();
			my $temp = ();
			my $level = 0; 
			while (my $row = <$file>) {
				if($row =~ m/{/){
					$level++; 
					$row =~ s/[{\t\n]//g;
					push(@{$temp}, $row);
				}elsif($row =~ m/}/){
					$level--;
					pop(@{$temp});
				}else{
					if($level == 0){
						if(!($row =~ m/#/) && $row =~ m/=/){
							my @items = doSplit($row);
							$values->{$items[0]} = $items[1]; 
						}
					}elsif($level == 1){
						if(!($row =~ m/#/) && $row =~ m/=/){
							my @items = doSplit($row);
							$values->{$temp->[0]}->{$items[0]} = $items[1]; 
						}
					}elsif($level == 2){
						if(!($row =~ m/#/) && $row =~ m/=/){
							my @items = doSplit($row);
							$values->{$temp->[0]}->{$temp->[1]}->{$items[0]} = $items[1]; 
						}
					}elsif($level == 3){
						if(!($row =~ m/#/) && $row =~ m/=/){
							my @items = doSplit($row);
							$values->{$temp->[0]}->{$temp->[1]}->{$temp->[2]}->{$items[0]} = $items[1]; 
						}
					}
				}
			}
			close($file);
			$self->app($values);
		}else{
			die "This Ressource isn't an App\n";
		}
	}

	sub doSplit(){
		my ($row) = @_; 
		my @items = split(/=/,$row);
		$items[0] =~ s/[\t\n]//g;		
		$items[1] =~ s/[\t\n]//g;
		return @items; 
	}

	sub getTest(){
		my ($self) = @_; 
		return $self->other()->{'testing'};
	}
}
1; 