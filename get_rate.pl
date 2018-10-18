#!/usr/bin/perl

die "Usage: perl make_time_mat.pl <WIG_List> <domain_bed> <OUT_FILE_PREFIX> <STEP>\nWIG_LIST - two column file: time wig_file_path" if(!$ARGV[3]);

BEGIN { push @INC, '/beevol/home/srinivas/code/perl_library' }
use ngs;

open(FILE,$ARGV[0]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$time = $temp[0];
	$tread = 0;
	$tread = &ngs::readwig($temp[1]);
	$dat{$time} = $tread;
}
close(FILE);

$step = $ARGV[3];


@times = ( sort {$a <=> $b} (keys(%dat))) ;

$last_time = $times[$#times];

open(RCODE,">>rcode") || die "$!\n";

open(FILE,$ARGV[1]) || die "$!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\t\n\ ]+/,$line;
	$chr = $temp[0];
	$chr =~s/^chr//;
	$st  = int( ($temp[1]/$step) + 0.5)*$step;
	$en  = int( ($temp[2]/$step) + 0.5)*$step;
	print "$chr $st $en\n";
	$outfile   = $ARGV[2]."_".$temp[0]."_".$temp[1]."_".$temp[2];
	$outfile_v = $ARGV[2].".val_".$temp[0]."_".$temp[1]."_".$temp[2];
	print RCODE "dat     <- read.csv(file='$outfile',sep=\"\\t\",header = F)\n";
	print RCODE "dat_n   <- dat[,c(2: ncol(dat) ) ]\n";
	print RCODE "cl      <- kmeans(dat_n,centers = 7, iter.max = 1000)\n";
	print RCODE "kgg     <- cbind(as.character(dat[,1]),cl\$cluster)\n";
	print RCODE "outfile <- sprintf(\"".$outfile."_7clust.kgg\",7)\n";
	print RCODE "write.table(kgg,file=outfile,col.names = F, row.names = F,quote = F)\n";
	open(OUT,">$outfile") || die "$!\n";
	open(VOUT,">$outfile_v") || die "$!\n";
	for($i=$st;$i<=$en;$i+=$step){
		$prev_t = -1;
		$prev_v = -1;
		$tread = ();
		%tread = %{$dat{$last_time}};
		$nval = 0;
		$nval = $tread{$chr}{$i};
		if($nval>0){
			$str = sprintf("%s_%s",$chr,$i);
			print OUT $str;
			print VOUT $str;
			foreach $j ( sort {$a <=> $b} (keys(%dat)) ){
				%tread = ();
				%tread = %{$dat{$j}};
				$val = 0; $noval = 0;
				$val   = $tread{$chr}{$i}/$nval if(exists $tread{$chr}{$i});
				$noval = $tread{$chr}{$i} if(exists $tread{$chr}{$i});
				print OUT "\t$val";
				print VOUT "\t$noval";
			}
			print OUT "\n";
			print VOUT "\n";
		}
	}
	close(OUT);
	close(VOUT);
}
close(FILE);
close(RCODE);
