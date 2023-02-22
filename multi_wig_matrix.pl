#!/usr/bin/perl

die "Usage: perl multi_wig_matrix.pl <WIG_List> <domain_bed> <OUT_FILE_PREFIX> <STEP>\nWIG_LIST - two column file: Prefix wig_file_path\nTime wig should be the first file\n" if(!$ARGV[3]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

open(FILE,$ARGV[0]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$pre = $temp[0];
	push(@pres,$pre);
	$tread = 0;
	$tread = &ngs::readwig($temp[1]);
	$dat{$pre} = $tread;
}
close(FILE);

$step = $ARGV[3];

open(FILE,$ARGV[1]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$chr = $temp[0];
	$chr =~s/^chr//;
	$st  = int( ($temp[1]/$step) + 0.5)*$step;
	$en  = int( ($temp[2]/$step) + 0.5)*$step;
	print "$chr $st $en\n";
	$outfile   = $ARGV[2]."_".$temp[0]."_".$temp[1]."_".$temp[2];
	
	open(OUT,">$outfile") || die "$!\n";
	#print OUT "Pos";
	$str = "Pos";
	for($i=0;$i<=$#pres;$i++){
		#print OUT "\t$pres[$i]";
		$str = $str."\t$pres[$i]";
	}
	#print OUT "\n";
	print OUT "$str\n";
	for($i=$st;$i<=$en;$i+=$step){
		$prev_t = -1;
		$prev_v = -1;
		$str = sprintf("%s_%s",$chr,$i);
		#print OUT $str;
		foreach $j (@pres){
			%tread = ();
			%tread = %{$dat{$j}};
			if(exists $tread{$chr}{$i}){
				$str = $str.sprintf("\t%f",$tread{$chr}{$i});
			}else{
				$str = $str."\tNA";
			}
			#print OUT "\t$val";
		}
		#if($str =~/NA/){
		#}else{
			print OUT "$str\n";
		#}
	}
	close(OUT);
}
close(FILE);
