#!/usr/bin/perl

die "Usage: perl profile_domains.pl <PD-WIG> <Log2-WIG> <Domain BED>\n" if(!$ARGV[2]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

($tread,$ar_tread) = &ngs::readwigArray($ARGV[0]);
%pdread    =    %{$tread};
@ar_pdread = @{$ar_tread};

$tread = &ngs::readwig($ARGV[1]);
%l2read  = %{$tread};

print STDERR "Done reading wigs\n";


($gw_med,$gw_n)= &ngs::median(\@ar_pdread);

print STDERR "Done finding median : $gw_med :: $gw_n\n";

open(BED, $ARGV[2]) || die "$!\n";
while(chomp($line=<BED>)){
	@temp = split /[\t\n\ ]+/,$line;
	$chr = $temp[0];
	$chr =~s/chr//;
	$start = int($temp[1]/25 + 0.5)*25;
	$end   = int($temp[2]/25 + 0.5)*25;
	$val  = 0;
	$lval = 0;
	$ct = 0;
	for($i=$start;$i<=$end;$i+=25){
		if(exists $pdread{$chr}{$i} ){
			$ct++;
			$val += $pdread{$chr}{$i};
			$lval+= $l2read{$chr}{$i};
		}
	}
	if($ct!=0){
		$val /= $ct;
		$lval /= $ct;
		print "$chr\t$temp[1]\t$temp[2]\t$temp[3]\t$val\t$lval\n";
	}
}
close(BED);
