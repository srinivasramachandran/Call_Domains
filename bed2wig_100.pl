die "Usage: perl bed2wig.pl <Bed FILE> <WIG FILE NAME> <MIN> <MAX>\n" if(!$ARGV[1]);

$GN = 100000000;

$min=$ARGV[2];
$max=$ARGV[3];

open(FILE,"/home/sramacha/JS/code/hg19_chr.sizes") || die "$!\n";
while(chomp($line=<FILE>)){
  @temp = split /[\ \s\n\t]+/, $line;
  $temp[0]=~s/chr//;
	print "$temp[0] $temp[1]\n";
	$chr_size{$temp[0]}=$temp[1];
}
close(FILE);

open(FILE,$ARGV[0]) || die "INPUT $!\n";
while(chomp($line=<FILE>)){
  $lno++;
  @temp = split /[\ \s\n\t]+/, $line;
  if($#temp != 5){
    print STDERR "Not regular BED line?\n$line\n";
  }elsif($temp[3]>=$min && $temp[3]<=$max){
		$temp[0]=~s/chr//;
    if(exists $chr_size{$temp[0]}){
    	$lower=int(($temp[1]/100) + 0.5);
    	$upper=int(($temp[2]/100) + 0.5);
    	for($i=$lower;$i<=$upper;$i++){
				if($i< ($chr_size{$temp[0]}/100)){
      		$read{$temp[0]}{$i}++;
      		$count++;
				}
   		}
		}
  }
  print STDERR "Count:$count\n" if($count%10000000==0 && $count>0);
  print STDERR "Line No:$lno\n" if($lno%1000000==0 && $lno>0);

}
print STDERR "Finished reading bed file\nCount=$count\nLines=$lno";
close(FILE);
open(OUT,">$ARGV[1]") || die "OUT $!\n";
print OUT "track type=wiggle_0\n";
foreach $i (keys (%read) ){
  print OUT "variableStep  chrom=chr$i span=100\n";
  %thash = %{$read{$i}};
  for($j=0;$j<($chr_size{$i}/100);$j++){
    if(exists $thash{$j}){
      $normval = $thash{$j}*$GN/$count ;
      print OUT ($j*100+1)." $normval\n";
    }
  }
}
close(OUT);
