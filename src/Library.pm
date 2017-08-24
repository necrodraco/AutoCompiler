#! /usr/bin/perl

package Library{
	use Moose; 
	use feature 'say';
	use Data::Dumper; 
	use POSIX qw/strftime/;

	sub sayPrint(){
		my ($self, $string) = @_;
		my $time = strftime "%d-%m-%Y %H:%M:%S ", localtime(time);
		say $time.$string; 
	}

	sub doCommand(){
		my ($self, $command, $flag) = @_; 
		if(defined($command) && $command ne ""){
			if($flag){
				$self->sayPrint('command: '.(Dumper $command)); 
			}
			system "$command"; 
		}else{
			$self->sayPrint('One Command was not set. ');
		}
	}
}
1;