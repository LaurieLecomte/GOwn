# GOwn: GO enrichment analysis Without Nightmares

This is a simplified GO enrichment analysis pipelines relying on GAWN's output.


1. Download GO database
```
cd 03_go_db
wget http://geneontology.org/ontology/go-basic.obo
```

2. Add required GAWN outputs for the assembly of interest
This pipelines uses the simplified annotation table and the `all_go_annotations.csv` file outputted by GAWN.

To produce the `all_go_annotations.csv` file from the `transcriptome.hits` file produced by GAWN's [`04_blast_transcriptome_on_swissprot.sh` script](https://github.com/enormandeau/gawn/blob/master/01_scripts/04_blast_transcriptome_on_swissprot.sh), one can use the `get_uniprot_info_from_gawn.sh` script (TO DO)


