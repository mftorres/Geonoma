REF='$HOME/pools/k55hyb_GUR2.fasta';
FILE='P13454_101_trimmfastp_paired.1.fastq.gz';

#nohup pigz -dc "${FILE%%.*}".1.fastq.gz -p 8 > "${FILE%%.*}".1.fastq &
#nohup pigz -dc "${FILE%%.*}".2.fastq.gz -p 8 > "${FILE%%.*}".2.fastq &

#java -jar $EBROOTPICARD/picard.jar CreateSequenceDictionary R=$HYB3 O=$HYB3
bwa index $REF

bwa mem -t 8 $REF <(pigz -dc "${FILE%%.*}".1.fastq.gz -p 8) <(pigz -dc "${FILE%%.*}".2.fastq.gz -p 8) | samtools view -@ 8 -q 20 -bSh -o k55hybGUR2_"${FILE%%.*}".bam -

samtools sort -@ 14 -o hyb3_"${FILE%%.*}".bam.srtd.bam hyb3_"${FILE%%.*}".bam;

# 2.2. Add group information to the BAM files
java -jar $EBROOTPICARD/picard.jar AddOrReplaceReadGroups -I hyb3_"${FILE%%.*}".bam.srtd.bam \
 -O hyb3_"${FILE%%.*}".srtd.wgrps.bam -RGID 4 -RGLB lib1 -RGPL illumina \
 -RGPU unit1 -RGSM $GROUP --TMP_DIR ./scratch $2> "$GROUP"_groupfix.out;

echo "fixing groups done with at `date`"
# 2.3. Sort BAMs by name
samtools sort -@ 14 -n -o hyb3_"${FILE%%.*}".srtdname.wgrps.bam hyb3_"${FILE%%.*}".srtd.wgrps.bam;

echo "sorting by name done with at `date`"
#rm hyb3_"${FILE%%.*}".bam
rm hyb3_"${FILE%%.*}".bam.srtd.bam
echo "removed .bam.srtd.bam at `date`"

# 2.4. Fix read mate information
samtools fixmate -@ 14 -m hyb3_"${FILE%%.*}".srtdname.wgrps.bam hyb3_"${FILE%%.*}".srtdname.wgrps.fxmt.bam;

echo "fixmate done with at `date`"
rm hyb3_"${FILE%%.*}".srtd.wgrps.bam
echo "removed .srtd.wgrps.bam at `date`"

# 2.5. Sort BAMs by coordinate
samtools sort -@ 14 -o "${FILE%%.*}".wg.srtcrd.fix.bam hyb3_"${FILE%%.*}".srtdname.wgrps.fxmt.bam;

echo "sort by coordinates done with at `date`"
rm hyb3_"${FILE%%.*}".srtdname.wgrps.bam
echo "removed .srtdname.wgrps.bam at `date`"

# 2.6. Mark duplicates
samtools markdup -@ 14 "${FILE%%.*}".wg.srtcrd.fix.bam "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam;
samtools index -@ 14 "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam;


samtools stats -@ 14 -c 0,2000,1 -i 10000 -r $HYB3 "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam > "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam.ALLstast

samtools stats -@ 14 -c 0,2000,1 -i 10000 -r $HYB3 -d "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam > "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam.nodupstast

echo "final, final, no va mas!"