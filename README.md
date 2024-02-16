# Investigating Orthogroups

In this sample dataset, we will download five Atadenovirus whole-genome sequences, select the protein FASTA, and identify orthogroups (orthologous genes) to make gene trees for each identified ortholog.

I typically download the files to my computer and rename them there (sorry!) but if you would like to, you can download them directly by following the link, going to amarel, typing the below command.

```
curl -OJX GET [link]
```

[Bovine Atadenovirus D](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_000845805.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

[Bearded Dragon Adenovirus 1](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_018591195.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

[Duck Adenovirus 1](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_000845945.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

[Odocoeilus Adenovirus 1 (deer)](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_002355065.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

[Lizard Adenovirus 2](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_000923975.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)


To download these genomes all at once, you can go to this link:
https://www.ncbi.nlm.nih.gov/datasets/genome/?taxon=100953

Download the first five links. 

![Uploading image.png…]()
