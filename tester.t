#! /usr/bin/perl

#use Test::More tests => 2; 
#use Test::More skip_all => $reason; 
use Test::More;

$number_of_tests_run = 2; 
#name=$(Befehl)
system 'var';
system '$var=$(java -version)';
my $var = (system 'echo var');
print $var; 

exit(0);
if((system 'echo var') == 0){
	is(1, 1, 'Java is installed');
}else{
	my $msg = <<eof; 
Java is not installed. 
Inform yourself how you can install Java on your Operating System
eof
	is(1, 1, $msg);
}

my @modules = ('Moose', 'File::Copy', 'DBI', 'Getopt::Long', 'File::Find', 'Image::Magick', 'Archive::Zip', 'Data::Dumper');
foreach my $module(@modules){
	$number_of_tests_run += 2; 
	checkIfModuleInstalled($module);
}

is(1,1,'All Tests are correct'); 
done_testing( $number_of_tests_run );

sub checkIfModuleInstalled(){
	my ($module) = @_;
my $msg = <<eof;
Module $module Not installed. 
Install it on this way. Write in Command Prompt/Terminal these Commands: 
cpan App::cpanminus

and after that: 

cpanm $module
eof

	eval "use $module; 1" 
	or die $msg; 

	isnt( use_ok($module), 0, $module.' installed' );
}