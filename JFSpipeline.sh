ls /home/jsarthy/henikoff/ngs/illumina/171107_SN367_1057_AH2LYVBCX2/bowtie2/JS_HsSc/*.bed > bed.list
cp ../101717/*.sh .
sh gen_wig.sh bed.list
ls $PWD/*.wig > wig.list
sh gen_ra.sh