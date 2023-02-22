#!/usr/bin/perl

#Calculate scores from wig files for each interval in a bed file.

die "Usage: perl bed_score.pl <PD_WIG> <IN_WIG> <bed> <STEP>\n" if(!$ARGV[2]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

$step=$ARGV[3];

$tread = &ngs::readwig($ARGV[1]);
%inread = %{$tread};

$tread = &ngs::readwig($ARGV[0]);
%pdread = %{$tread};

open(FILE,$ARGV[2]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$chr = $temp[0];
	$chr =~s/^chr//;
	$st  = int( ($temp[1]/$step) + 0.5)*$step;
	$en  = int( ($temp[2]/$step) + 0.5)*$step;
	print STDERR "$chr $st $en ".($en-$st)."\n";
	if( ($en-$st)>$step){
		$in_score=0;
		$pd_score=0;
		for($i=$st;$i<=$en;$i+=$step){
			$in_score+=$inread{$chr}{$i};
			$pd_score+=$pdread{$chr}{$i};
		}
		if($in_score==0 && $pd_score==0){
			$l2_score=0;
		}elsif($in_score==0){
			$l2_score=20;
		}elsif($pd_score==0){
			$l2_score=-20;	
		}else{
			$l2_score = log ( $pd_score/$in_score ) / log(2);
		}
		print "$temp[0]\t$temp[1]\t$temp[2]\t$l2_score\t$pd_score\t$in_score\n";
	}
}
close(FILE);
