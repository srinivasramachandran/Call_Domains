#!/usr/bin/perl

die "Usage: perl make_time_mat.pl <WIG_List> <domain_bed> <OUT_FILE_PREFIX> <STEP>\nWIG_LIST - two column file: Prefix wig_file_path\nTime wig should be the first file\n" if(!$ARGV[3]);

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

open(RCODE,">>rcode") || die "$!\n";
print RCODE "outfile <- sprintf(\"Reg_Coefs\")\n";
print RCODE "cat(c(\"Pos\"";
for($i=1;$i<$#pres+1;$i++){
	print RCODE ",\"val.$pres[$i]\",\"pval.$pres[$i]\"";
}
print RCODE ",\"rsq\",\"F-statistic P-value\"\"\\n\"),file=outfile,append = T,sep=\"\\t\")\n";



open(FILE,$ARGV[1]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$chr = $temp[0];
	$chr =~s/^chr//;
	$st  = int( ($temp[1]/$step) + 0.5)*$step;
	$en  = int( ($temp[2]/$step) + 0.5)*$step;
	print "$chr $st $en\n";
	$outfile   = $ARGV[2]."_".$temp[0]."_".$temp[1]."_".$temp[2];
	print RCODE "dat     <- read.csv(file='$outfile',sep=\"\\t\",header = T)\n";
	print RCODE "fit     <- lm($pres[0] ~ ";
	for($i=1;$i<$#pres;$i++){
		print RCODE " $pres[$i] +";
	}
	print RCODE " $pres[$#pres], data=dat)\n";
	
	for($i=1;$i<=$#pres;$i++){
		$j=$i+1;
		print RCODE "val.$pres[$i] <- summary(fit)\$coefficients[$j,1]\npval.$pres[$i] <- summary(fit)\$coefficients[$j,4]\n";
	}
	print RCODE "rsq <- summary(fit)\$r.squared\n";
	print RCODE "f <- summary(fit)\$fstatistic\nfpvalue <- pf(f[1], f[2], f[3], lower=FALSE)\n";
	print RCODE "cat(c(\"$outfile\"";
	for($i=1;$i<$#pres+1;$i++){
		print RCODE ",val.$pres[$i],pval.$pres[$i]";
	}
	print RCODE ",rsq,fpvalue,\"\\n\"),file=outfile,append = T,sep=\"\\t\")\n";
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
		if($str =~/NA/){
		}else{
			print OUT "$str\n";
		}
	}
	close(OUT);
}
close(FILE);
close(RCODE);
