#!/usr/bin/perl

#Two conditions --> > 2*genome-wide average ; log2(PD/IN) > 2

die "Usage: perl call_domains.pl <PD-WIG> <Log2-WIG> <Median cut-off> <Log2 Cutoff> <domain-size>\n" if(!$ARGV[4]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
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
	$near_cutoff = 3*$ARGV[4]/4;
	$in_between_flag=-1;
	foreach $j ( sort {$a <=> $b} keys(%{$pdread{$i}})){
		if($pdread{$i}{$j} > $ave_cutoff && $l2read{$i}{$j} > $l2_cutoff){
			#$temp = $j+10;
			#print FILE "$i\t$j\t$temp\n";
			if($prev==-1){
				$start=$j; #starting new domain for first time on the chromosome
				$prev=$j;
				#push(@tarray,$l2read{$i}{$j});
				$val+=$l2read{$i}{$j};
				$ct++;
				print STDERR "Con 1 $prev $start\n";
			}elsif($prev>($j-$near_cutoff) && $prev<$j){
				$val+=$l2read{$i}{$j};
				$ct++;
				$prev=$j;
				$flag=1; # Start new domain
				$in_between_flag=-1;
				print STDERR "Con 2 $prev $start\n";
			}elsif($in_between_flag==1){
					$in_between_flag=-1;
					$val+=$l2read{$i}{$j};
					$ct++;
					$prev=$j;
					print STDERR "Con 3 $prev $start\n";
			}
		}elsif($l2read{$i}{$j}>0 && $pdread{$i}{$j}>$gw_med && $in_between_flag!=0){
			$in_between_flag=1;
			print STDERR "Con 4 $j\n";
		}else{
			if($flag==1){
				$width = $prev - $start;
				print STDERR "Con 5 $j $prev $start $in_between_flag $width";
				if($width >= $ARGV[4] ){ 
					$val/=$ct if($ct>0);
					print "chr$i\t$start\t$prev\t$width\t$val\n";
					print STDERR "\tCon 5-1";
				}
				print STDERR "\n";
			}
			$flag=0;
			$val=0;
			$ct=0;
			$prev=-1;
			$in_between_flag=0;
		}	
	}
}
#close(FILE);
