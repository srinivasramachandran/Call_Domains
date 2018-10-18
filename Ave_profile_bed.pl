#!/usr/bin/perl

die "Usage: perl Ave_profile_bed.pl <WIG> <Peaks> <step> <OUT-FILE>\n" if(!$ARGV[3]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

$tread = &ngs::readwig($ARGV[0]);
%read  = %{$tread};

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
	for($m=$peak-$window;$m<=$peak+$window;$m+=$step){
		$position = $m - $peak;
		if(exists $read{$chr}{$m}){
			$normval=$read{$chr}{$m};
			push(@{$hash{$position}},$normval); 			
		}else{
			$normval=0;
		}
	}
}


open(OUT, ">$ARGV[3].Ave") || die "OUTPUT FILE $!\n";
for($j=2*$step-$window;$j<=$window-2*$step;$j+=$step){
	$#tarray=-1;
	$mean=0;$se=0;$number=0;
	
	@tarray=@{$hash{$j}};
	($mean,$se,$number) = &mean_se(\@tarray) if($#tarray>-1);
	
	$#tarray=-1;
	$rmean=0;$rse=0;$rnumber=0;
	
	for($k=$j-20;$k<=$j+20;$k+=10){
		push(@tarray,@{$hash{$k}});
	}
	($rmean,$rse,$rnumber) = &mean_se(\@tarray) if($#tarray>-1);
	print OUT "$j $rmean $rse $rnumber $mean $se $number\n" if($number>0);

}
close(OUT);

sub mean_se {
  my @ar = @{$_[0]};
  my $sum=0;
  foreach my $ii (@ar){
    $sum+=$ii;
  }
  my $mean=$sum/($#ar+1);
  $sum=0;
  foreach my $ii (@ar){
    $x=($ii-$mean)**2;
    $sum+=$x;
  }
  my $se=(sqrt($sum))/($#ar+1);
	my $num = $#ar+1;
  return ($mean,$se,$num);
}
