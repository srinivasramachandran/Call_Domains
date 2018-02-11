#!/usr/bin/perl

#Two conditions --> > 2*genome-wide average ; log2(PD/IN) > 2

die "Usage: perl call_domains.pl <PD-WIG> <Log2-WIG> <Median cut-off> <Log2 Cutoff> <domain-size>\n" if(!$ARGV[4]);

BEGIN { push @INC, '/home/sramacha/perl_library' }
use ngs;

($tread,$ar_tread) = &ngs::readwigArray($ARGV[0]);
%pdread    =    %{$tread};
@ar_pdread = @{$ar_tread};

#$bin=10;
#
#foreach $i ( @ar_pdread ){
#	$binpos = int(($i-($bin/2))/$bin + 0.5);
#	$vals{$binpos}++;
#}
#
#open(FILE,">vals.hist") || die "$!\n";
#
#foreach $i ( sort {$a <=> $b} (keys(%vals) ) ){
#	print FILE "$i $vals{$i}\n";
#}
#
#close(FILE);

$tread = &ngs::readwig($ARGV[1]);
%l2read  = %{$tread};

print STDERR "Done reading wigs\n";


($gw_med,$gw_n)= &ngs::median(\@ar_pdread);

$ave_cutoff = $ARGV[2]*$gw_med;
$l2_cutoff  = $ARGV[3];

print STDERR "Done finding median : $gw_med :: $gw_n cutoff :: $ave_cutoff\n";

#open(FILE,">cutoff.bed") || die "$!\n";

foreach $i ( keys(%pdread) ){
	print STDERR "chr $i\n";
	$prev=-1;
	#$#tarray=-1;
	$flag=0;
	$val=0;
	$ct=0;
	foreach $j ( sort {$a <=> $b} keys(%{$pdread{$i}})){
		if($pdread{$i}{$j} > $ave_cutoff && $l2read{$i}{$j} > $l2_cutoff){
			#$temp = $j+10;
			#print FILE "$i\t$j\t$temp\n";
			if($prev==-1){
				$start=$j;
				$prev=$j;
				#push(@tarray,$l2read{$i}{$j});
				$val+=$l2read{$i}{$j};
				$ct++;
			}elsif($prev>($j-500) && $prev<$j ){
				$val+=$l2read{$i}{$j};
				$ct++;
				$prev=$j;
				$flag=1;
			}else{
				$width = $prev - $start;
				if($flag==1 && $width >= $ARGV[4]){
					$val/=$ct if($ct>0);
					print "chr$i\t$start\t$prev\t$width\t$val\n";
					$flag=0;
					$val=0;
					$ct=0;
				}
				$prev=$j;
				$start=$j;
			}
		} 
	} 
}
#close(FILE);
