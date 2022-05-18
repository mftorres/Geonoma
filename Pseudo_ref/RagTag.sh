# ragtag by chromosome for computational restrictions
# then I'll add all chromosomes together
# scaffold a query assembly

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 Pltd; do ragtag.py scaffold elaeis/chr${i}.fna spadesk55ill_ont/tk23hybfastpk55_scaffolds.fasta -o k55hyb_EGchr"${i}" -t 4; done

# get only the first sequence (chromosome) per output file above. That represents the most complete chromosome sequence from EG to which Geonoma contigs map. Remove the rest, that do not have the ragtag flag in the header and that represent the contigs from geonoma that do not map to the chromosome. we need to do this to repeate the contig sequences .. as all get concatenated in each chromosome file as none matching chromosomes.
# to prevent added file names etc:

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 Pltd; do grep -A 1 'RagTag' k55hyb_EGchr${i}/ragtag.scaffold.fasta >> K55_EGR1_mapped.fasta; done

# map the contigs to the geonoma+EG ref of only chromosomes
ragtag.py scaffold K55_EGR1_mapped.fasta spadesk55ill_ont/tk23hybfastpk55_scaffolds.fasta -o k55hyb_R2EG -t 4 -q 9

# busco
busco -i k55hyb_R2EG/ragtag.scaffold.fasta -l liliopsida -m genome -c 2 -o k55hyb_R2EG_busco --long --force

grep -A 1 'RagTag' k55hyb_R2EG/ragtag.scaffold.fasta > K55_EGR2_mapped.fasta

ragtag.py scaffold K55_EGR2_mapped.fasta spadesk55ill_ont/tk23hybfastpk55_scaffolds.fasta -o k55hyb_R3EG -t 4 -q 9

busco -i k55hyb_R3EG/ragtag.scaffold.fasta -l liliopsida -m genome -c 4 -o k55hyb_R3EG_busco --long --force

grep -A 1 'RagTag' k55hyb_R3EG/ragtag.scaffold.fasta > K55_EGR3_mapped.fasta

# mapping to geonoma undata Gundata_psdref.fa
ragtag.py scaffold Gundata_psdref.fa spadesk55ill_ont/tk23hybfastpk55_scaffolds.fasta -o k55hyb_GU -t 4 

busco -i k55hyb_GU/ragtag.scaffold.fasta -l liliopsida -m genome -c 2 -o k55hyb_GU_busco --long --force
# C:84.9%[S:77.0%,D:7.9%],F:9.2%,M:5.9%,n:3236

grep -A 1 'RagTag' k55hyb_GU/ragtag.scaffold.fasta > K55_GUR1_mapped.fasta

ragtag.py scaffold K55_GUR1_mapped.fasta spadesk55ill_ont/tk23hybfastpk55_scaffolds.fasta -o k55hyb_GUR2 -t 4
busco -i k55hyb_GUR2/ragtag.scaffold.fasta -l liliopsida -m genome -c 2 -o k55hyb_GUR2_busco --long --force
# C:84.8%[S:76.9%,D:7.9%],F:9.3%,M:5.9%,n:3236

quast.py k55hyb_R3EG/ragtag.scaffold.fasta \
         k55hyb_GUR2/ragtag.scaffold.fasta \
         hyb3.fasta \
         --min-contig 200 \
         --threads 4 \
         --split-scaffolds \
         --eukaryote \
         --gene-finding

