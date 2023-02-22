#!/usr/bin/perl

die "Usage: perl Ave_profile_bed_domains.pl <WIG> <Peaks> <step> <OUT-FILE>\n" if(!$ARGV[3]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

open(FILE,$ARGV[0]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	@pos = split /_/,$temp[0];
	$chr = $pos[0];
	$loc = $pos[1];
	$tval{$chr}{$loc} = $temp[1];
	$pred_val{$chr}{$loc} = $temp[2];
	print STDERR "$chr $loc $temp[2]\n";
}
close(FILE);


$window=20000;

$step = $ARGV[2];

# read Peaks 
open(NUC,$ARGV[1]) || die "PEAK $!\n";
while($i=<NUC>){ 
	chomp($i);
	@temp=split/[\t\n\ ]+/,$i;
	$peak= (int( ($temp[1]+$temp[2])/(2*$step)+0.5))*$step;
	$chr=$temp[0];
	$chr=~s/chr//;
	$st = (int( $temp[6]+0.5)/$step)*$step;
	$en = (int( $temp[7]+0.5)/$step)*$step;
	print STDERR "Ori: $i\n$peak $st $en\t";
	$ct = 0; $sum=0;
	for($m=$st;$m<=$en;$m+=$step){
		$normval=0;
		if(exists $pred_val{$chr}{$m}){
			$normval=$pred_val{$chr}{$m};
		}
		$sum+=$normval;
		$ct++;
	}
	$sum/=$ct;
	print STDERR "AVE:$sum\n";
	if($sum>0){
		for($m=$st;$m<=$en;$m+=$step){
			$position = $m - $peak;
			if(exists $pred_val{$chr}{$m}){
				$normval=$pred_val{$chr}{$m}/$sum;
				push(@{$hash{$position}},$normval); 			
			}else{
				$normval=0;
				push(@{$hash{$position}},$normval); 			
			}
		}
	}
}

open(OUT, ">$ARGV[3].Ave") || die "OUTPUT FILE $!\n";
for($j=2*$step-$window;$j<=$window-2*$step;$j+=$step){
	$#tarray=-1;
	$mean=0;$se=0;$number=0;
	
	@tarray=@{$hash{$j}};
	($mean,$se,$number) = &ngs::mean_se(\@tarray) if($#tarray>-1);
	
	$#tarray=-1;
	$rmean=0;$rse=0;$rnumber=0;
	
	for($k=$j-2*$step;$k<=$j+2*$step;$k+=$step){
		push(@tarray,@{$hash{$k}});
	}
	($rmean,$rse,$rnumber) = &ngs::mean_se(\@tarray) if($#tarray>-1);
	print OUT "$j $rmean $rse $rnumber $mean $se $number\n" if($number>0);

}
close(OUT);
