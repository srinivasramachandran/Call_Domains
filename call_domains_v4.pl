#!/usr/bin/perl

# 2*genome-wide median ; calculate log enrichment over whole putative domain

die "Usage: perl call_domains.pl <PD-WIG> <IN-WIG> <Median cut-off> <domain-size>\n" if(!$ARGV[3]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

($tread,$ar_tread) = &ngs::readwigArray($ARGV[0]);
%pdread    =    %{$tread};
@ar_pdread = @{$ar_tread};

($tread,$ar_tread) = &ngs::readwigArray($ARGV[1]);
%inread  = %{$tread};
@ar_inread = @{$ar_tread};

print STDERR "Done reading wigs\n";


($gw_med,$gw_n)= &ngs::median(\@ar_pdread);
($gw_inmed,$gw_inn)= &ngs::median(\@ar_inread);

$ave_cutoff = $ARGV[2]*$gw_med;

print STDERR "Done finding median : $gw_med :: $gw_n cutoff :: $ave_cutoff\n";

#open(FILE,">cutoff.bed") || die "$!\n";

foreach $i ( keys(%pdread) ){
	print STDERR "chr $i\n";
	$prev=-1;
	#$#tarray=-1;
	$flag=0;
	$val=0;
	$ct=0;
	$near_cutoff = 3*$ARGV[3]/4;
	$in_between_flag=-1;
	foreach $j ( sort {$a <=> $b} keys(%{$pdread{$i}})){
		if($pdread{$i}{$j} > $ave_cutoff){
			#$temp = $j+10;
			#print FILE "$i\t$j\t$temp\n";
			if($prev==-1){
				$start=$j; #starting new domain for first time on the chromosome
				$prev=$j;
				#push(@tarray,$l2read{$i}{$j});
				$val_pd+=$pdread{$i}{$j};
				$val_in+=$inread{$i}{$j};
				$ct++;
				print STDERR "Con 1 $prev $start\n";
			}elsif($prev>($j-$near_cutoff) && $prev<$j){
				$val_pd+=$pdread{$i}{$j};
				$val_in+=$inread{$i}{$j};
				$ct++;
				$prev=$j;
				$flag=1; # Start new domain
				$in_between_flag=-1;
				print STDERR "Con 2 $prev $start\n";
			}elsif($in_between_flag==1){
					$in_between_flag=-1;
					$val_pd+=$pdread{$i}{$j};
					$val_in+=$inread{$i}{$j};
					$ct++;
					$prev=$j;
					print STDERR "Con 3 $prev $start\n";
			}
		}elsif($pdread{$i}{$j}>$gw_med && $in_between_flag!=0){
			$in_between_flag=1;
			print STDERR "Con 4 $j\n";
		}else{
			if($flag==1){
				$width = $prev - $start;
				print STDERR "Con 5 $j $prev $start $in_between_flag $width";
				if($width >= $ARGV[3] ){ 
					if($val_in!=0){
						$val= log ( $val_pd/$val_in)/log(2) if($ct>0);
					}else{
						$val= log ( $val_pd/ ($gw_inmed*$ct))/log(2) if($ct>0);
					}
					print "chr$i\t$start\t$prev\t$width\t$val\n";
					print STDERR "\tCon 5-1";
				}
				print STDERR "\n";
			}
			$flag=0;
			$val_pd=0;
			$val_in=0;
			$ct=0;
			$prev=-1;
			$in_between_flag=0;
		}	
	}
}
