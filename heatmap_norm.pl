#!/usr/bin/perl

die "Usage: perl heatmap.pl <WIG> <Peak Bed> <step>\n" if(!$ARGV[1]);

$step = 100;
$step = $ARGV[2] if($ARGV[2]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

$tread = &ngs::readwig($ARGV[0]);
%read  = %{$tread};

$window=20000;

open(NUC,$ARGV[1]) || die "PEAK $!\n";
while($i=<NUC>){ 
	chomp($i);
	@temp=split /[\t\n\ ]+/,$i;
	$peak= (int( ($temp[1]+$temp[2])/(2*$step)+0.5))*$step;
	print STDERR "$peak\n";
	$chr=$temp[0];
	$chr=~s/^chr//;
	$ct=0;$sum=0;
	for($m=$peak-$window;$m<=$peak+$window;$m+=$step){
		if(exists $read{$chr}{$m} && $read{$chr}{$m}>$sum){
			$sum = $read{$chr}{$m};
			$ct++;
		}
	}
	if($ct!=0){
		for($m=$peak-$window;$m<=$peak+$window;$m+=$step){
			$val=1;
			$val = $read{$chr}{$m}/$sum if(exists $read{$chr}{$m});
			print "$val\t";
		}
	}
	print "\n";
}
