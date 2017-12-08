#! /usr/bin/perl

package Library{
	use Moose; 
	use feature 'say';
	use Data::Dumper; 
	use POSIX qw/strftime/;

	sub getTime(){
		return strftime "%d-%m-%Y %H:%M:%S ", localtime(time); 
	}

	sub sayPrint(){
		my ($self, $string) = @_;
		my $time = $self->getTime();
		say $time.$string; 
	}

	sub doCommand(){
		my ($self, $command, $flag) = @_; 
		if(defined($command) && $command ne ''){
			if($flag){
				$self->sayPrint('command: '.(Dumper $command)); 
			}
			system "$command"; 
		}else{
			$self->sayPrint('One Command was not set. ');
		}
	}

	sub moveMultiple(){
		my ($self, $fileWildCard, $target) = @_;
		foreach my $file(glob $fileWildCard){
			rename($file, $target.$file);
		}
	}
}
1;