#!/usr/bin/perl


die "Usage: perl wig_param_print.pl <WIG>\n" if(!$ARGV[0]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

print STDERR "PD: $ARGV[0]\n";

$tread  = &ngs::readwig($ARGV[0]);
%pdread =    %{$tread};

print STDERR "Done reading wigs\n";

######### PD MEDIAN ##########################
foreach $i (keys(%pdread)){
	push(@tval_pd,values(%{$pdread{$i}}));
}
@val_pd = sort {$a <=> $b} @tval_pd;
$pos = int( ($#val_pd+1)/2);
$pd_median = $val_pd[$pos];
$pd_low = $val_pd[0];
$pd_high = $val_pd[$#val_pd];

print STDERR "Median: $pd_median Low: $pd_low High: $pd_high\n";
##############################################

######### histogram ##########################

$ct=0;
foreach $i (@val_pd) {
	$hist{$i}++;
	$ct++;
}

foreach $i (sort {$a<=>$b} (keys(%hist))){
	$val = $hist{$i}/$ct;
	print "$i $val $hist{$i}\n";
}
