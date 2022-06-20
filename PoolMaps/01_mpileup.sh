REF='$HOME/pools/k55hyb_GUR2.fasta';
SAMPLE='P13454_103';

# extract header, sort, select contigs > 200 bases, and create BED file
samtools view -@ 14 -h ${SAMPLE}_trimmfastp_paired.wg.srtcrd.fix.mkdp.bam | \
grep '^@SQ' | sort -V -k3 > "${SAMPLE}"_header.txt
awk '{split($3,a,":"); if (a[2] > 200) {print $2,$3}}' "${SAMPLE}"_header.txt | sed -r 's/SN:|LN://g' > "${SAMPLE}"_selected.file

samtools view -@ 14 -hb -L P13454_103_selected.file -q 20 -F 1024 -o ${SAMPLE}_trimmfastp_paired.wg.srtcrd.fix.mkdp.L200.bam ${SAMPLE}_trimmfastp_paired.wg.srtcrd.fix.mkdp.bam 

ls *L200.bam > mpileup_bamlist.txt
samtools mpileup -b mpileup_bamlist.txt -B -f $REF -o poolsALLdedup_L200.mpileup;
