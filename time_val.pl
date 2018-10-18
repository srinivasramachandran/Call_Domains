#!/usr/bin/perl

die "Usage: perl make_time_mat.pl <WIG_List> <domain_bed> <OUT_FILE_PREFIX> <STEP>\nWIG_LIST - two column file: time wig_file_path" if(!$ARGV[3]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

open(FILE,$ARGV[0]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$time = $temp[0];
	$tread = 0;
	$tread = &ngs::readwig($temp[1]);
	$dat{$time} = $tread;
}
close(FILE);

$step = $ARGV[3];


@times = ( sort {$a <=> $b} (keys(%dat))) ;

$last_time = $times[$#times];

open(FILE,$ARGV[1]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$chr = $temp[0];
	$chr =~s/^chr//;
	$st  = int( ($temp[1]/$step) + 0.5)*$step;
	$en  = int( ($temp[2]/$step) + 0.5)*$step;
	print "$chr $st $en\n";
	for($i=$st;$i<=$en;$i+=$step){
		$prev_t = -1;
		$prev_v = -1;
		$tread = ();
		%tread = %{$dat{$last_time}};
		$nval = 0;
		$nval = $tread{$chr}{$i};
		if($nval>0){
			$str = sprintf("%s_%s",$chr,$i);
			print OUT $str;
			print VOUT $str;
			%thash = ();
			foreach $j ( sort {$a <=> $b} (keys(%dat)) ){
				%tread = ();
				%tread = %{$dat{$j}};
				$val = 0; 
				$val   = $tread{$chr}{$i}/$nval if(exists $tread{$chr}{$i});
				$thash{$j} = $val;
			}
			$t = &get_pos(\%thash); 
			$twig{$chr}{$i}=$t;
		}
	}
}
close(FILE);
$jnk = &ngs::writeWig(\%twig,$ARGV[2],$step);
open(OUT,">$ARGV[2]") || die "OUT writeWig $outfile $!\n";
print OUT "track type=wiggle_0\n";
foreach $i (keys (%twig) ){
	print OUT "variableStep  chrom=chr$i span=$step\n";
	%thash = %{$twig{$i}};
	foreach $j ( sort {$a<=>$b} keys(%thash) ){
		print OUT "$j $twig{$i}{$j}\n";
	}
}
close(OUT);

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
