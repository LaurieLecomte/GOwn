#!/bin/sh

# Use a conda env with goatools installed 

# srun -p small -c 1 -J run_goatools -o log/run_goatools_%j.log /bin/sh 01_scripts/run_goatools.sh FILE 0 &

# VARIABLES
CAND_BED=$1
OVERLAP_WIN=$2

ANNOT_TABLE="02_genome_annot/genome_annotation_table_simplified.txt"
GO_ANNOT="02_genome_annot/all_go_annotations.csv"
GO_DB="03_go_db/go-basic.obo"
#GO_DB="03_go_db/go-basic2022-07-01.obo"

OVERLAP_DIR="05_overlap"
GO_DIR="06_go_enrichment"
FILT_DIR="07_go_filt"

MAX_FDR=0.1
MIN_LEVEL=1

# LOAD REQUIRED MODULES
module load bedtools/2.31.1

# 1. Get background set of genes from annotation table
less $ANNOT_TABLE | cut -f5 | sort | uniq > $GO_DIR/"$(basename -s .txt $ANNOT_TABLE)".background.IDs.txt


# 2. Get overlap of candidate sites and known genes
bedtools window -a $ANNOT_TABLE -b $CAND_BED -w $OVERLAP_WIN > $OVERLAP_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp.table

echo "$(less $OVERLAP_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp.table | cut -f1,5 | sort | uniq | wc -l) unique genes (or duplicated genes on different chromosomes) located at < $OVERLAP_WIN bp of an candidate site"

# 3. Extract gene IDs from shared outliers table
less $OVERLAP_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp.table | cut -f5 | sort | uniq > $GO_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp_outlierIDs.txt

# 4. Perform GO enrichment analysis genes overlapping candidate sites
find_enrichment.py --pval=0.05 --indent \
  --obo $GO_DB \
  $GO_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp_outlierIDs.txt \
  $GO_DIR/"$(basename -s .txt $ANNOT_TABLE)".background.IDs.txt \
  $GO_ANNOT \
  --outfile $GO_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp_GO.csv
  
# 5. Filter results
Rscript 01_scripts/filter_GO.R $GO_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp_GO.csv $MAX_FDR $MIN_LEVEL $FILT_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp_GO

# Simplify filtered results
#less $FILT_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp_GO_fdr"$MAX_FDR"_depth"$MIN_LEVEL".csv | cut -f1,4-6,8,13 | perl -pe 's/^[.]+(GO\:[0-9\.e\-]+)/\1/' > $FILT_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp_GO_fdr"$MAX_FDR"_depth"$MIN_LEVEL".simpl.txt

# Simplify even further for running REVIGO online
#less $FILT_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp_GO_fdr"$MAX_FDR"_depth"$MIN_LEVEL".simpl.txt | tail -n+2 | cut -f1,6 | perl -pe 's/^[.]+(GO\:[0-9\.e\-]+)/\1/' > $FILT_DIR/"$(basename -s .bed $CAND_BED)"_"$OVERLAP_WIN"bp_GO_fdr"$MAX_FDR"_depth"$MIN_LEVEL".GO_pval.txt
