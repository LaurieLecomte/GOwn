#!/bin/sh

# Use a conda env with goatools installed 

# srun -p small -c 1 -J overlapping_genes -o log/overlapping_genes_%j.log /bin/sh 01_scripts/overlapping_genes.sh FILE 0 &

# VARIABLES
CAND_BED=$1
OVERLAP_WIN=$2

ANNOT_TABLE="02_genome_annot/genome_annotation_table_simplified.txt"

OVERLAP_DIR="05_overlap"


# LOAD REQUIRED MODULES
module load bedtools/2.31.1


# 1. For each variant/region, get overlapping genes within a given window (around variant/region)
bedtools window -a $CAND_BED -b $ANNOT_TABLE -w $OVERLAP_WIN > $OVERLAP_DIR/"$(basename -s .bed $CAND_BED)"_overlap_genes_"$OVERLAP_WIN"bp.table

# 2. For each variant/region, get **number** of overlapping genes within a given window (around variant/region)
bedtools window -a $CAND_BED -b $ANNOT_TABLE -w $OVERLAP_WIN -c > $OVERLAP_DIR/"$(basename -s .bed $CAND_BED)"_overlap_genes_"$OVERLAP_WIN"bp_count.table

