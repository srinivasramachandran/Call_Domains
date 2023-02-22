#!/usr/bin/perl

# 2*genome-wide median ; calculate PD and input enrichment over whole domain and print it.

die "Usage: perl call_domains.pl <PD-WIG> <IN-WIG> <Hard Cut-off> <domain-size>\n" if(!$ARGV[3]);

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

$ave_cutoff = $ARGV[2];

print STDERR "Done finding median : $gw_med :: $gw_n cutoff :: $ave_cutoff\n";


foreach $i ( keys(%pdread) ){
	print STDERR "chr $i\n";
	$prev=-1;
	$flag=0;
	$val=0;
	$ct=0;
	$near_cutoff = 3*$ARGV[3]/4;
	$in_between_flag=-1;
	foreach $j ( sort {$a <=> $b} keys(%{$pdread{$i}})){
		if($pdread{$i}{$j} > $ave_cutoff){
			if($prev==-1){
				$start=$j; #starting new domain 
				$prev=$j;
				$val_pd+=$pdread{$i}{$j};
				$val_in+=$inread{$i}{$j};
				$ct++;
				print STDERR "Con 1 $prev $start\n";
			}elsif($prev>($j-$near_cutoff) && $prev<$j){ #Allow jump of 3/4 of minimum domain size (for small gaps)
				$val_pd+=$pdread{$i}{$j};									 #If more than 3/4 of min domain size, end prev one and start a new one.
				$val_in+=$inread{$i}{$j};
				$ct++;
				$prev=$j;
				$flag=1; # Inside a domain
				$in_between_flag=-1;
				print STDERR "Con 2 $prev $start\n";
			}elsif($in_between_flag==1){ #If jump is more than 3/4 of minimum domain size, check if intervening 
					$in_between_flag=-1;		 #region was > (1/2)*cutoff
					$val_pd+=$pdread{$i}{$j};
					$val_in+=$inread{$i}{$j};
					$ct++;
					$prev=$j;
					print STDERR "Con 3 $prev $start\n";
			}
		}elsif($pdread{$i}{$j}>$ave_cutoff/2 && $in_between_flag!=0){
			$in_between_flag=1;
			print STDERR "Con 4 $j\n";
		}else{
			if($flag==1){
				$width = $prev - $start;
				print STDERR "Con 5 $j $prev $start $in_between_flag $width";
				if($width >= $ARGV[3] ){ 
				#	if($val_in!=0){
				#		$val= log ( $val_pd/$val_in)/log(2) if($ct>0);
				#	}else{
				#		$val= log ( $val_pd/ ($gw_inmed*$ct))/log(2) if($ct>0);
				#	}
					print "chr$i\t$start\t$prev\t$width\t$val_pd\t$val_in\n";
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
