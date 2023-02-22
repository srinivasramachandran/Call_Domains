#!/usr/bin/perl

die "Usage: perl heatmap.pl <PD_WIG> <IN_WIG> <OUT_WIG> <STEP>\n" if(!$ARGV[3]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

$t_pdread = &ngs::readwig($ARGV[0]);
%pdread  = %{$t_pdread};

$t_inread = &ngs::readwig($ARGV[1]);
%inread  = %{$t_inread};

######### IN MEDIAN ##########################
foreach $i (keys(%inread)){
	push(@tval_in,values(%{$inread{$i}}));
}
@val_in = sort {$a <=> $b} @tval_in;
$pos = int( ($#val_in+1)/2);
$in_median = $val_in[$pos];

print STDERR "IN Median: $in_median\n";
##############################################



foreach $i ( keys(%pdread) ){
	foreach $j (keys(%{$pdread{$i}})){
		if(exists $inread{$i}{$j}){
			$val{$i}{$j} = log ($pdread{$i}{$j}/$inread{$i}{$j}) / log(2);
		}else{
			$val{$i}{$j} = log ($pdread{$i}{$j}/$in_median) / log(2);
		}
	}
}

open(OUT,">$ARGV[2]") || die "$!\n";
print OUT "track type=wiggle_0\n";
foreach $i ( keys(%val) ){
	print OUT "variableStep  chrom=chr$i span=$ARGV[3]\n";
	foreach $j ( sort {$a <=> $b} ( keys(%{$val{$i}}) ) ){
		print OUT "$j $val{$i}{$j}\n";
	}
}
