REF='$HOME/pools/k55hyb_GUR2.fasta';
FILE='P13454_101_trimmfastp_paired.1.fastq.gz';

#nohup pigz -dc "${FILE%%.*}".1.fastq.gz -p 8 > "${FILE%%.*}".1.fastq &
#nohup pigz -dc "${FILE%%.*}".2.fastq.gz -p 8 > "${FILE%%.*}".2.fastq &

#java -jar $EBROOTPICARD/picard.jar CreateSequenceDictionary R=$HYB3 O=$HYB3
bwa index $REF

bwa mem -t 8 $REF <(pigz -dc "${FILE%%.*}".1.fastq.gz -p 8) <(pigz -dc "${FILE%%.*}".2.fastq.gz -p 8) | samtools view -@ 8 -q 20 -bSh -o k55hybGUR2_"${FILE%%.*}".bam -

samtools sort -@ 12 -o k55hybGUR2_"${FILE%%.*}".bam.srtd.bam k55hybGUR2_"${FILE%%.*}".bam;

# 2.2. Add group information to the BAM files
# conda create -n openjdk openjdk
# conda activate openjdk
# git clone https://github.com/broadinstitute/picard.git
# cd picard
# ./gradlew shadowJar
PICARD='build/libs'
java -jar $PICARD/picard.jar AddOrReplaceReadGroups -I k55hybGUR2_"${FILE%%.*}".bam.srtd.bam \
 -O k55hybGUR2_"${FILE%%.*}".srtd.wgrps.bam -RGID 1 -RGLB lib1 -RGPL illumina \
 -RGPU unit1 -RGSM P13454_101; 


echo "fixing groups done with at `date`"
# 2.3. Sort BAMs by name
samtools sort -@ 14 -n -o k55hybGUR2_"${FILE%%.*}".srtdname.wgrps.bam k55hybGUR2_"${FILE%%.*}".srtd.wgrps.bam;

echo "sorting by name done with at `date`"
#rm k55hybGUR2_"${FILE%%.*}".bam
rm k55hybGUR2_"${FILE%%.*}".bam.srtd.bam
echo "removed .bam.srtd.bam at `date`"

# 2.4. Fix read mate information
samtools fixmate -@ 14 -m k55hybGUR2_"${FILE%%.*}".srtdname.wgrps.bam k55hybGUR2_"${FILE%%.*}".srtdname.wgrps.fxmt.bam;

echo "fixmate done with at `date`"
rm k55hybGUR2_"${FILE%%.*}".srtd.wgrps.bam
echo "removed .srtd.wgrps.bam at `date`"

# 2.5. Sort BAMs by coordinate
samtools sort -@ 14 -o "${FILE%%.*}".wg.srtcrd.fix.bam k55hybGUR2_"${FILE%%.*}".srtdname.wgrps.fxmt.bam;

echo "sort by coordinates done with at `date`"
rm hyb3_"${FILE%%.*}".srtdname.wgrps.bam
echo "removed .srtdname.wgrps.bam at `date`"

# 2.6. Mark duplicates
samtools markdup -@ 14 "${FILE%%.*}".wg.srtcrd.fix.bam "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam;
samtools index -@ 14 "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam;


samtools stats -@ 14 -c 0,2000,1 -i 10000 -r $HYB3 "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam > "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam.ALLstast

samtools stats -@ 14 -c 0,2000,1 -i 10000 -r $HYB3 -d "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam > "${FILE%%.*}".wg.srtcrd.fix.mkdp.bam.nodupstast

echo "final, final, no va mas!"
