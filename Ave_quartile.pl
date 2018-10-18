#!/usr/bin/perl

die "Usage: perl AveRelDyad.pl <WIG> <Peaks> <OUT-FILE>\n" if(!$ARGV[2]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

$tread = &ngs::readwig($ARGV[0]);
%read  = %{$tread};

$window=55000;

# read Peaks 
open(NUC,$ARGV[1]) || die "PEAK $!\n";
while($i=<NUC>){ 
	chomp($i);
	@temp=split/[\t\n\ ]+/,$i;
	$peak= (int($temp[3]/100+0.5))*100;
	$chr=$temp[1];
	$quartile=$temp[0];
	$str=$temp[4];
	for($m=$peak-$window;$m<=$peak+$window;$m+=100){
		$position = $m - $peak;
		$position *= -1 if($str eq "-");
		if(exists $read{$chr}{$m}){
			$normval=$read{$chr}{$m};
			push(@{$qhash{$quartile}{$position}},$normval); 			
			push(@{$hash{$position}},$normval); 			
		}else{
			$normval=0;
		}
	}
}

open(OUT, ">Comb.$ARGV[2]") || die "OUTPUT FILE $!\n";
for($j=20-$window;$j<=$window-20;$j+=10){
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

foreach $i (keys(%qhash) ){
	open(OUT,">q$i.$ARGV[2]") || die "OUTPUT FILE $!\n";
	for($j=20-$window;$j<=$window-20;$j+=10){ 		
		
		$#tarray=-1;
		$mean=0;$se=0;$number=0;
		
		@tarray=@{$qhash{$i}{$j}};
		($mean,$se,$number) = &mean_se(\@tarray) if($#tarray>-1);
		
		$#tarray=-1;
		$rmean=0;$rse=0;$rnumber=0;
		
		for($k=$j-20;$k<=$j+20;$k+=10){
			push(@tarray,@{$qhash{$i}{$k}});
		}
		($rmean,$rse,$rnumber) = &mean_se(\@tarray) if($#tarray>-1);
		print OUT "$j $rmean $rse $rnumber $mean $se $number\n" if($number>0);
	
	}
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
