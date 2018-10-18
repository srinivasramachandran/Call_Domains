#!/usr/bin/perl

die "Usage: perl bed2ave_time_mat.pl <time_WIG> <domain_bed> <STEP>\n" if(!$ARGV[2]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

$step=$ARGV[2];

$tread = &ngs::readwig($ARGV[0]);
%read = %{$tread};

open(FILE,$ARGV[1]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$chr = $temp[0];
	$chr =~s/^chr//;
	$st  = int( ($temp[1]/$step) + 0.5)*$step;
	$en  = int( ($temp[2]/$step) + 0.5)*$step;
	print STDERR "$chr $st $en\n";
	$#time_ar=-1;
	for($i=$st;$i<=$en;$i+=$step){
		push(@time_ar,$read{$chr}{$i});
	}
	($mt,$mse,$mn) = &ngs::mean_se(\@time_ar);
	print "$temp[0]\t$temp[1]\t$temp[2]\t$mt\t$mse\t$mn\n";
}
close(FILE);
