#!/usr/bin/perl


die "Usage: perl gen_ra.pl <PD-WIG> <IN-WIG> <domain-size/2> <PREFIX> <IN_STEP_SIZE> <OUT_STEP_SIZE>\n" if(!$ARGV[4]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

print STDERR "PD: $ARGV[0] IN: $ARGV[1] Domain size: $ARGV[2] Prefix: $ARGV[3]\n";

$tread  = &ngs::readwig($ARGV[0]);
%pdread =    %{$tread};

$tread = &ngs::readwig($ARGV[1]);
%inread  = %{$tread};

print STDERR "Done reading wigs\n";

foreach $i (keys(%inread)){
	push(@tval_in,values(%{$inread{$i}}));
}
@val_in = sort {$a <=> $b} @tval_in;
$pos = int( ($#val_in+1)/2);
$in_median = $val_in[$pos];

print STDERR "Finished median\n";

$win=$ARGV[2];
$step=$ARGV[4];
$incr=100;
$incr=$ARGV[5] if($ARGV[5]);

open(OUT1,">PD.$ARGV[3]") || die "OUT PD $!\n";
open(OUT2,">LOG2.$ARGV[3]") || die "OUT LOG2 $!\n";


foreach $i ( keys(%pdread) ){
	print STDERR "$i\n";
	print OUT1 "variableStep  chrom=chr$i span=$incr\n";
	print OUT2 "variableStep  chrom=chr$i span=$incr\n";
	$prev=-1*$incr;
	foreach $j ( sort {$a <=> $b} keys(%{$pdread{$i}})){
		if($j-$prev>=$incr){
			$in_count=0;
			$pd_count=0;
			$l2=0;
			$ct=0;
			#print STDERR "$j\n";
			for($k=$j-$win;$k<=$j+$win;$k+=$step){
				$in_count+=$inread{$i}{$k};
				$pd_count+=$pdread{$i}{$k};
				$ct++;
			}
			$in_count/=$ct;
			$pd_count/=$ct;
			print OUT1 "$j $pd_count\n";
			if($in_count!=0 && $pd_count!=0){
				$l2 = log($pd_count/$in_count)/ log(2) ;
				#print STDERR "$pd_count $in_count $l2\n";
				print OUT2 "$j $l2\n";
			}elsif($pd_count!=0){
				$l2 = log($pd_count/$in_median)/ log(2) ;
				 print OUT2 "$j $l2\n";
			}
			$prev=$j;
		}
	}
}

print STDERR "Finished writing all wigs\n";
