#!/usr/bin/perl

die "Usage: perl heatmap.pl <WIG> <Peak list>\n" if(!$ARGV[1]);

BEGIN { push @INC, '/home/sramacha/perl_library' }
use ngs;

$tread = &ngs::readwig($ARGV[0]);
%read  = %{$tread};

$window=20000;

# read Peaks and print heatmap
#print "Gene\t";
#for($m=-$window;$m<=$window;$m+=10){
#	print "pos_$m\t";
#}
#print "\n";

open(NUC,$ARGV[1]) || die "PEAK $!\n";
while($i=<NUC>){ 
	chomp($i);
	@temp=split/[\t\n\ ]+/,$i;
	$peak= (int( ($temp[1]+$temp[2])/20+0.5))*10+1;
	$chr=$temp[0];
	#Normalizer...
	$ct=0;$norm=0;
	for($m=$peak-$window;$m<=$peak+$window;$m+=10){
		if(exists $read{$chr}{$m}){
			$ct++;
			$norm+=$read{$chr}{$m};
		}
	}
	$norm = ($norm*10/($window*2+1));
	print STDERR "$chr $peak $norm\n";
	for($m=$peak-$window;$m<=$peak+$window;$m+=10){
		$normval=0;
	#	for($j=$m-70;$j<=$m+70;$j+=10){
	#		if(exists $read{$chr}{$j}){
	#			$normval+=$read{$chr}{$m}/$norm;
	#		}
	#	}
	#	$normval/=11;
		$normval = $read{$chr}{$m}/$norm;
		print "$normval\t";
	}
	print "\n";
}
