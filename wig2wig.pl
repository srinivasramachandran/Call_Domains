#!/usr/bin/perl

die "Usage: perl heatmap.pl <IN_WIG> <OUT_WIG>\n" if(!$ARGV[1]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

$tread = &ngs::readwig($ARGV[0]);
%read  = %{$tread};

foreach $i ( keys(%read) ){
	foreach $j (keys(%{$read{$i}})){
		$pos = int( ($j/100) + 0.5 )*100;
		$val{$i}{$pos}+=$read{$i}{$j};
		$count{$i}{$pos}++;
	}
}

open(OUT,">$ARGV[1]") || die "$!\n";
print OUT "track type=wiggle_0\n";
foreach $i ( keys(%val) ){
	print OUT "variableStep  chrom=chr$i span=100\n";
	foreach $j ( sort {$a <=> $b} ( keys(%{$val{$i}}) ) ){
		$nval = $val{$i}{$j}/$count{$i}{$j};
		print OUT "$j $nval\n";
	}
}
