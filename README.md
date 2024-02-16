# Investigating Orthogroups to Make Species and Gene Trees

OBJECTIVE: In this sample dataset, we will download five Atadenovirus whole-genome sequences, select the protein FASTAs, and identify orthogroups, which are orthologous genes across the species. The purpose is to make gene trees for each identified ortholog. We will then reconcile all of those gene trees into a species tree. You can see why we might want to do such a thing [here - you can just read the abstract](https://www.cell.com/trends/ecology-evolution/fulltext/S0169-5347(01)02203-0). Basically, each gene may have a slightly different evolutionary history and thus a slightly different relationship. So it's important to reconcile all of the gene trees we make into one big species tree.

We will do that in three computational steps plus a fourth, local visualization step.
1) OrthoFinder (identifies orthologous genes)
2) IQTREE (predicts each gene tree under a selected model of evolution)
3) ASTRAL (reconciles each gene tree into a single species)
4) FigTree (visualizes trees).


## Downloading Files

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

### Since downloading the FASTA files, unzipping them, and all that are a little bit annoying, I have provided them in this folder for your convenience in the "data" folder.


## OrthoFinder

### Setting Up for OrthoFinder

The next thing you will need is you will need the OrthoFinder.yml file. This is a CONDA environment file that will set up the OrthoFinder program in your list of conda environments on Amarel. You can put it in the same folder as the FASTA files.

```
conda env create -f orthofinder.yml
conda activate orthofinder # make sure that the environment installed properly
```

Once the OrthoFinder environment has been verified to work correctly, we can make a script that actually runs the program. Feel free to copy the script below (change the file paths as needed).

### Running OrthoFinder

```
#!/bin/bash
#SBATCH --partition=cmain                    # which partition to run the job, options are in the Amarel guide
#SBATCH --exclude=gpuc001,gpuc002               # exclude CCIB GPUs
#SBATCH --job-name=orthofinder                        # job name for listing in queue
#SBATCH --mem=5G                               # memory to allocate in Mb
#SBATCH -n 20                                   # number of cores to use
#SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --time=1:00:00                       # maximum run time days-hours:minutes:seconds
#SBATCH --requeue                                # restart and paused or superseeded jobs

echo "Load conda needed for orthofinder"

module purge
eval "$(conda shell.bash hook)"
conda activate orthofinder

cd /projects/f_geneva_1/chfal/test_c4l/

echo "Create variables for Orthofinder"

ulimit -n 2400

orthofinder -f /projects/f_geneva_1/chfal/test_c4l/ -M msa                  # Run full OrthoFinder analysis on FASTA format proteomes in specfied directory

# orthofinder [options] -f <dir1> -b <dir2>     # Add new species in to a previous run and run new analysis

```

This job takes about 30 seconds to run. While it is running, go back to your main directory and make a new folder for the next program we are going to use, IQTREE.

```
mkdir iqtree
```

OrthoFinder then will make a lot of files (!) in the same directory you sent the run off at.


OrthoFinder makes a list of single copy orthologue sequences, which it associates with (from what I can tell) random, sequential numbers. Therefore, we need to take the list of single-copy orthologue sequences, and select those associated named gene trees from the gene trees file. This code does this, but you have to move to the MultipleSequenceAlignment folder and run it there. SO:

```
cd OrthoFinder/YOUR_DATE_HERE/MultipleSequenceAlignments
```

When you are in that folder, you will see a list of orthogroups that OrthoFinder has identified.
```
cat ../Orthogroups/Orthogroups_SingleCopyOrthologues.txt | xargs -n 1 -I {} cp {}.fa /projects/f_geneva_1/chfal/test_c4l/iqtree

```

## IQTREE

So now you should have all of your orthologous gene groups (orthologues) that were the output of OrthoFinder, one in each file. Now we are going to make gene trees from these files - one each! We will use the program IQTree.

IQTree works by first running a simulation to select the best model of evolution for each orthogroup and then it creates a gene tree based on that model of evolution.


The syntax for an IQTree command is: 

```
iqtree -m TEST -s ORTHOGROUP.fasta
```

The -m TEST flag means that we will be testing for the model of evolution.


Seen below is an individual slurm script for IQTree. This slurm script should exist in the IQTREE folder.

```
#!/bin/bash
#SBATCH --partition=cmain                    # which partition to run the job, options are in the Amarel guide
#SBATCH --account=general
#SBATCH --constraint=oarc
#SBATCH --exclude=halc068               # exclude CCIB GPUs
#SBATCH --job-name=iqtree                        # job name for listing in queue
#SBATCH --mem=10G                               # memory to allocate in Mb
#SBATCH -n 20                                   # number of cores to use
#SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --time=5:00:00                       # maximum run time days-hours:minutes:seconds
#SBATCH --requeue                                # restart and paused or superseeded jobs

echo "Load conda needed for orthofinder"

module purge
eval "$(conda shell.bash hook)"
conda activate iqtree

iqtree -m TEST -s ${1}
```

However, there are 15 orthogroups so it is kind of annoying to submit all 15 different jobs. Here we will make a loop file, called "run_loop_iqtree.sh". You will want to change the below information to be specific to your file paths on Amarel.

```
for FILE in /projects/f_geneva_1/chfal/test_c4l/iqtree/*.fasta; do
       echo "$FILE"
       #sbatch run_iqtree.sh ${FILE}
       #sleep=.05
done
```

Then you will want to go back out and make this an executable file using this command:

```
chmod 755 run_loop_iqtree.sh
```

The output of IQTREE creates many things. It creates a tree file, which is what you need for Astral, and a Log file, which telsls you what analysis was run and what the best model of evolution was.

