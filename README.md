# Investigating Orthogroups

In this sample dataset, we will download five Atadenovirus whole-genome sequences, select the protein FASTA, and identify orthogroups (orthologous genes) to make gene trees for each identified ortholog.

I typically download the files to my computer and rename them there but if you would like to, you can download them directly by following the link, going to amarel, typing the below command.

```
curl -OJX GET [link]
```

[Bovine Atadenovirus D](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_000845805.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

[Bearded Dragon Adenovirus 1](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_018591195.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

[Duck Adenovirus 1](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_000845945.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

[Odocoeilus Adenovirus 1 (deer)](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_002355065.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

[Lizard Adenovirus 2](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_000923975.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

The workflow goes that once you have downloaded each file, you will want to unzip it, go into the data folder, and look for the file that says "protein.faa". You will want to rename that file to the name of the species (if you have forgotten the species, you can "head" the file before renaming it).

## Since downloading the FASTA files, unzipping them, and all that are a little bit annoying, I have provided them in this folder for your convenience in the "data" folder.


The next thing you will need is you will need the OrthoFinder.yml file. This is a CONDA environment file that will set up the OrthoFinder program in your list of conda environments on Amarel.
