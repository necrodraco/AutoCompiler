#! /usr/bin/perl

package SqlManager{
	use Moose; 
	use lib 'src'; 
	extends 'Library';
	
	use DBI;
	use Finder; 
	use File::Copy;

	has 'path' => ('is' => 'rw', 'required' => 1, ); 
	has 'fileName' => ('is' => 'rw', 'required' => 1, ); 
	has 'prevName' => ('is' => 'rw', 'required' => 1, ); 
	has 'replacing' => ('is' => 'rw', 'required' => 1, );
	has 'dbh' => ('is' => 'rw', );

	sub createPrev(){
		my ($self) = @_;
		
		my $src = $self->path().'/'.$self->fileName(); 
		my $dest = $self->path().'/'.$self->prevName(); 
		copy($src, $dest) or die "Copy failed: $!";
		my $dbargs = {'AutoCommit' => 1, 'PrintError' => 1};
		$self->dbh(DBI->connect("dbi:SQLite:dbname=$dest", "", "", $dbargs));
	}

	sub doNormal(){
		my ($self, $path) = @_;
		if(defined($path) && $path ne ''){
			$self->update($path);
		}
	}

	sub activateAnime(){
		my ($self) = @_;
		$self->doSqlCommand(
			'update texts set name = name || "(Anime)" 
			WHERE id IN(
				select d.id 
				FROM datas d 
				JOIN texts t 
				ON d.id = t.id AND t.name NOT LIKE "%(%)"
				WHERE d.ot NOT IN(1,2,3)
			)'
		); 
		$self->doSqlCommand('update datas set ot = 3 where ot = 4');
	}

	sub movePrev(){
		my ($self) = @_;
		$self->dbh()->disconnect();
		my $src = $self->path().'/'.$self->prevName(); 
		my $dest = $self->replacing();
		$self->sayPrint('src: '.$src);
		$self->sayPrint('dest: '.$dest);
		copy($src, $dest) or die "Copy failed: $!";
	}

	sub doSqlCommand(){
		my ($self, $statement, $flag) = @_; 
		if($flag){
			$self->sayPrint('Sql query: '.($statement)); 
		}
		$self->dbh()->do($statement)or die "$DBI::errstr\n";
	}

	sub update(){
		my ($self, $path) = @_;
		my $finder = Finder->new('path' => $path);
		my $cdbs = $finder->findCDB();
		$self->sayPrint('Updates CDB File');
		foreach my $cdbFile(@{$cdbs}){
			$self->doSqlCommand('attach "'.$cdbFile.'" as toMerge');
			$self->doSqlCommand('insert or ignore into datas select * from toMerge.datas');
			$self->doSqlCommand('insert or ignore into texts select * from toMerge.texts');
			$self->doSqlCommand('detach toMerge');
		}
		$self->sayPrint('Finished Updating');
	}
}
1; 