#!/usr/bin/perl

die "Usage: perl heatmap.pl <IN_WIG> <bed> <OUT_WIG> <step_size>\n" if(!$ARGV[2]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

$step_size = 100;
$step_size = $ARGV[3] if($ARGV[3]);

print STDERR "STEP: $step_size\n";


$tread = &ngs::readwig($ARGV[0]);
%read  = %{$tread};


open(FILE,$ARGV[1]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$chr = $temp[0];
	$chr =~s/^chr//;
	$st  = int( ($temp[1]/$step_size) - 0.5)*$step_size;
	$en  = int( ($temp[2]/$step_size) + 0.5)*$step_size;
	print "Chr:$chr $st $en\n";
	for($i=$st;$i<=$en;$i+=$step_size){	
		$wig{$chr}{$i}=$read{$chr}{$i} if(exists $read{$chr}{$i});
	}
}
close(FILE);

open(OUT, ">$ARGV[2]") || die "$!\n";
print OUT "track type=wiggle_0\n";
foreach $i ( sort {$a <=> $b} ( keys(%wig) ) ){
	print OUT "variableStep  chrom=chr$i span=$step_size\n";
	foreach $j (sort {$a <=> $b} (keys(%{$wig{$i}}))){
		print OUT "$j $wig{$i}{$j}\n";
	}
}
close(OUT);
