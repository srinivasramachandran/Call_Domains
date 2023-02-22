#!/usr/bin/perl


die "Usage: perl gen_ra_v2.pl <PD-WIG> <domain-size/2> <PREFIX> <IN_STEP_SIZE> (OUT_STEP_SIZE same as in step size)\n" if(!$ARGV[3]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

print STDERR "PD: $ARGV[0] Domain size: $ARGV[1] Prefix: $ARGV[2]\n";

$tread  = &ngs::readwig($ARGV[0]);
%pdread =    %{$tread};

$win=$ARGV[1]; #1000 usually
$step=$ARGV[3];

open(OUT1,">$ARGV[2]") || die "OUT PD $!\n";

foreach $i ( keys(%pdread) ){
	foreach $j ( sort {$a <=> $b} keys(%{$pdread{$i}})){
		for($k=$j-$win;$k<=$j+$win;$k+=$step){
			$out_pos{$i}{$k}=1;
		}
	}
}



foreach $i ( keys(%out_pos) ){
	print STDERR "$i\n";
	print OUT1 "variableStep  chrom=chr$i span=$step\n";
	foreach $j ( sort {$a <=> $b} keys(%{$out_pos{$i}})){
		$pd_count=0;
		$ct=0;
		for($k=$j-$win;$k<=$j+$win;$k+=$step){
			$pd_count+=$pdread{$i}{$k};
			$ct++;
		}
		$pd_count/=$ct;
		print OUT1 "$j $pd_count\n";
	}
}

print STDERR "Finished writing all wigs\n";
