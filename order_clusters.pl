#!/usr/bin/perl

open(FILE,$ARGV[0]) || die "list of files $!\n";
while(chomp($line=<FILE>)){
	open(DAT,$line) || die "$line $!\n";
	while(chomp($f=<DAT>)){
		@temp = split /[\t\n\ ]+/,$f;
		$val{$line}{$temp[0]}=$temp[1];
	}
	close(DAT);
}
close(FILE);

foreach $i ( keys(%val) ){
	%temp_hash = %{$val{$i}};
	$pos{$i} = &get_pos(\%temp_hash);
}

open(OUT,">$ARGV[1]") || die "$!\n";

$ct=1;
$str="plot ";
foreach $i (sort {$pos{$a} <=> $pos{$b}} (keys %pos) ){
	$str = $str."'$i' w lp,";
	print OUT "$i $pos{$i}\n";
	print "$i\n";
}

close(OUT);

print STDERR "$str\n";

sub get_pos{
	my $href = $_[0];
	my %thash = %{$href};
	my $prev=-1;
	my $next=-1;
	foreach my $j (sort {$a<=>$b} (keys(%thash)) ){
		if($thash{$j}<=0.4){
			$prev = $j;
		}elsif($thash{$j}>=0.4 && $next==-1){
			$next = $j;
		}
	}
	my $slope = ($thash{$next}-$thash{$prev})/($next-$prev);
	my $c = ($thash{$prev}-$slope*$prev);
	my $cutoff = (0.4 - $c)/$slope;
	return($cutoff);
}
