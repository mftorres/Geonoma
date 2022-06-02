REF='$HOME/pools/k55hyb_GUR2.fasta';
SAMPLE='P13454_104';

# extract header, sort, select contigs > 200 bases, and create BED file
samtools view -@ 14 -h ${SAMPLE}_trimmfastp_paired.wg.srtcrd.fix.mkdp.bam | \
grep '^@SQ' | sort -V -k3 > "${SAMPLE}"_header.txt
awk '{split($3,a,":"); if (a[2] > 200) {print $2,$3}}' "${SAMPLE}"_header.txt | sed -r 's/SN:|LN://g' > "${SAMPLE}"_selected.txt
