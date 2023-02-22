#!/usr/bin/perl


die "Usage: perl gen_ra.pl <PD-WIG> <domain-size/2> <PREFIX> <IN_STEP_SIZE> <OUT_STEP_SIZE>\n" if(!$ARGV[3]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

print STDERR "PD: $ARGV[0] Domain size: $ARGV[1] Prefix: $ARGV[2]\n";

$tread  = &ngs::readwig($ARGV[0]);
%pdread =    %{$tread};

$win=$ARGV[1]; #1000 usually
$step=$ARGV[3];
$incr=100;
$incr=$ARGV[4] if($ARGV[4]);

open(OUT1,">$ARGV[2]") || die "OUT PD $!\n";


foreach $i ( keys(%pdread) ){
	print STDERR "$i\n";
	print OUT1 "variableStep  chrom=chr$i span=$incr\n";
	$prev=-1*$incr;
	foreach $j ( sort {$a <=> $b} keys(%{$pdread{$i}})){
		if($j-$prev>=$incr){
			$pd_count=0;
			$ct=0;
			#print STDERR "$j\n";
			for($k=$j-$win;$k<=$j+$win;$k+=$step){
				$pd_count+=$pdread{$i}{$k};
				$ct++;
			}
			$pd_count/=$ct;
			print OUT1 "$j $pd_count\n";
			$prev=$j;
		}
	}
}

print STDERR "Finished writing all wigs\n";
