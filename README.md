# Investigating Orthogroups to Make Species and Gene Trees

OBJECTIVE: In this sample dataset, we will download five Atadenovirus whole-genome sequences, select the protein FASTAs, and identify orthogroups, which are orthologous genes across the species. The purpose is to make gene trees for each identified ortholog. We will then reconcile all of those gene trees into a species tree. You can see why we might want to do such a thing [here - you can just read the abstract](https://www.cell.com/trends/ecology-evolution/fulltext/S0169-5347(01)02203-0). Basically, each gene may have a slightly different evolutionary history and thus a slightly different relationship. So it's important to reconcile all of the gene trees we make into one big species tree.

We will do that in three computational steps plus a fourth, local visualization step.
1) OrthoFinder (identifies orthologous genes)
2) IQTREE (predicts each gene tree under a selected model of evolution)
3) ASTRAL (reconciles each gene tree into a single species)
4) FigTree (visualizes trees).

### Directory explanations
- `test_c4l/`
  - this folder is kind of the main folder. we'll run orthofinder here from here and save all our sequences here.
  - `OrthoFinder/`
    - OrthoFinder makes its own directory where it puts its results.
    - `Feb_16_Results/ OR WHATEVER DATE IT IS WHEN YOU RUN IT`
      - this contains a bunch of other folders. The imoprtant ones are
           - `Orthogroups`
           - `MultipleSequenceAlignments`
  - `iqtree`
    - Where we run IQTree analysis
  - `ASTRAL`
      - Where we download and run ASTRAL


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

[White Sturgeon Adv 1](https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_006400995.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT)

WHITE STURGEON is our outgroup as it is an ichtadenovirus.


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

OrthoFinder then will make a lot of files (!) in the same directory you sent the run off at. You actually don't need all the files. OrthoFinder makes a list of single copy orthologue sequences, which it associates with (from what I can tell) random but sequential numbers. Therefore, we need to take the list of single-copy orthologue sequences, and select those associated named gene trees from the gene trees file. This code does this, but you have to move to the MultipleSequenceAlignment folder and run it there. SO:

```
cd OrthoFinder/YOUR_DATE_HERE/MultipleSequenceAlignments
```

When you are in that folder, you will see a list of orthogroups that OrthoFinder has identified. Here is where you will run the below command, again changing the file paths to yours.

```
cat ../Orthogroups/Orthogroups_SingleCopyOrthologues.txt | xargs -n 1 -I {} cp {}.fa /projects/f_geneva_1/chfal/test_c4l/iqtree
```

## IQTREE

So now you should have all of your orthologous gene groups (orthologues) that were the output of OrthoFinder, one in each file. Now we are going to make gene trees from these files - one each! We will use the program IQTree. We don't need to download IQTree since it is already downloaded and within the Geneva lab's shared applications. So, what we can do, is follow the instructions below to access shared modules.

To use shared modules you will need to add these lines to your path.

Edit your bash profile in your home directory
```
cd
nano .bash_profile
```
In this file, there is a line labeled: `# User specific environment and startup programs`

Paste these commands **underneath** that line
```
module use /projects/community/modulefiles
PATH=$PATH:$HOME/.local/bin:$HOME/bin:$HOME/last/bin:/projects/f_geneva_1/.shared_apps/bin
export PATH
```
Save and exit the file, then run this command
```
source .bash_profile
```
Then you can test it by simply typing `iqtree` in the command line and it should pop up.


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

However, there are 15 orthogroups (at least in my run) so it is kind of annoying to submit all 15 different jobs. Here we will make a loop file, called "run_loop_iqtree.sh". You will want to change the below information to be specific to your file paths on Amarel.

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

You can then run that loop through this command:

```
./run_loop_iqtree.sh
```

While that is running you can go back to the head directory and make a new directory for ASTRAL.

```
mkdir astral
```


The output of IQTREE creates many things. It creates a tree file, which is what you need for Astral, and a Log file, which tells you what analysis was run and what the best model of evolution was. It can be important to look at both files, especially if you are interested in what model of evolution you need to use.

Tree files are the gene tree for that specific orthogroup in Newick format.


```
cat *.treefile > input_astral.tre

mv input_astral.tre ../astral
```



## ASTRAL

Astral is a Java-based program that is downloaded from a Zip file (link [here](https://github.com/smirarab/ASTRAL/raw/master/Astral.5.7.8.zip).

To download this, make another new directory in Amarel.

```
cd astral
wget https://github.com/smirarab/ASTRAL/raw/master/Astral.5.7.8.zip
unzip Astral.5.7.8.zip
```

Then you can run Astral which I typically run as an interactive job. Here is the code for an interactive job.

```
srun -p p_ccib_1 --job-name "name" --cpus-per-task 1 --mem-per-cpu 10g --time 01:00:00 --pty bash

module load java

```

This is the syntax for the Astral command. Since you are running it as an interactive job it will just "freeze" for a few seconds while it runs on that screen and then you will get an output file tree.

```
java -jar Astral/astral.5.7.8.jar -i input_astral.tre -o output_tree.tre 2> astral_run.log
```

I NEED TO FIND THE R CODE I MADE
