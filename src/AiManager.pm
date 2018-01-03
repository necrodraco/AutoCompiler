#! /usr/bin/perl

package AiManager{
	use Moose; 
	use lib 'src'; 
	extends 'Library';

	use Data::Dumper; 
	use File::Copy;

	has 'destination' => ('is' => 'rw', 'required' => 1, );
	has 'aioption' => ('is' => 'rw', 'required' => 1, );

	sub doAi(){
		my ($self) = @_;
		
		my $finder = Finder->new('path' => 'ai'); 
		my $list = $finder->findAiDecks();
		if(defined($self->aioption()->{'custom'})
			 && $self->aioption()->{'custom'} == 1){
			my $finder = Finder->new('path' => 'ai_custom'); 
			my $list = $finder->findAiDecks();
		}
		if(defined($self->aioption()->{'all'})
			 && $self->aioption()->{'all'} == 1){
			$self->sayPrint('has all ai');
			foreach my $name(keys %{$list}){
				$list->{$name}->{'stat'} = 1; 
			}
		}else{
			$self->sayPrint('hasn\'t all ai');
			foreach my $ai(keys %{$self->aioption()}){
				$ai .= '.ydk';
				if($ai =~ m/ai_/i && defined($list->{$ai})){
					$self->sayPrint($ai.'was setted');
					$list->{$ai}->{'stat'} = 1; 
				}
			}
		}
		$finder->clearFinder(); 
		$self->copyAi($list);
	}

	sub copyAi(){
		my ($self, $list) = @_;
		$self->sayPrint('list: '.(Dumper $list).' destination:'.(Dumper $self->destination()).'');
		$self->doCommand('rm '.$self->destination().'/assets/ai/deck/*.ydk');
		while(my ($name, $ai) = each %{$list}){
			if(defined($ai->{'stat'}) && $ai->{'stat'} == 1){
				copy($ai->{'path'}, $self->destination().'/assets/ai/deck/'.$name);
				#$self->doCommand('cp '.$name.' '.$self->destination().'/assets/ai/deck');
			}
		}
	}
}
1; 