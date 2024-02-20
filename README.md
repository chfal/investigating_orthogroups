# Investigating Orthogroups to Make Species and Gene Trees

OBJECTIVE: In this sample dataset, we will download five Atadenovirus whole-genome sequences, select the protein FASTAs, and identify orthogroups, which are orthologous genes across the species. The purpose is to make gene trees for each identified ortholog. We will then reconcile all of those gene trees into a species tree. You can see why we might want to do such a thing [here - you can just read the abstract](https://www.cell.com/trends/ecology-evolution/fulltext/S0169-5347(01)02203-0). Basically, each gene may have a slightly different evolutionary history and thus a slightly different relationship. So it's important to reconcile all of the gene trees we make into one big species tree.

We will do that in three computational steps plus a fourth, local visualization step.
1) OrthoFinder (identifies orthologous genes)
2) IQTREE (predicts each gene tree under a selected model of evolution)
3) ASTRAL (reconciles each gene tree into a single species)
4) FigTree (visualizes trees).

### Directory explanations
- `investigating_orthogroups/`
  - this folder is kind of the main folder. we'll run orthofinder here from here and save all our changed sequences here.
  - `Data/`
  - This is where the original starting data is, but you will change the fasta files and move them back to `investigating_orthogroups`
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

## Getting files

Get this repository into your directory on Amarel by Git Cloning.

git clone https://github.com/chfal/investigating_orthogroups/

Fasta files are located in the `investigating_orthogroups/data` folder. There is one for each species and they are each a protein FASTA downloaded off of Genbank. If you want to see the links directly, they are in the `links_to_files.md` document on this page.

WHITE STURGEON is our outgroup as it is an ichtadenovirus.


The first thing you will want to do is you will want to change the names of the FASTA file headers. You can do that with the script called `rename.sh` which is located in the data folder. The reason you need to do this is currently, all of the FASTA file headers are the name of that protein and an accession number. Orthofinder will think that those FASTA headers are literally different species and cause issues downstream.

The rename.sh script may not be an executable if you have directly cloned this repository. So to make it executable you can run the commands below:

```
cd investigating_orthogroups/data
chmod 755 rename.sh # this makes the script executable
./rename.sh # this makes the script run
```

The contents of the rename file are below: 

```
#!/bin/bash

for FILE in *.fasta;
do
 awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $FILE > changed_${FILE}
done
```

You will want to move the renamed FASTA files back to the investigating_orthogroups directory. Do not move the original files.

```
mv changed* ../
```

## OrthoFinder

### Setting Up for OrthoFinder

The next thing you will need is you will need the `orthofinder.yml` file. This is a CONDA environment file that will set up the OrthoFinder program in your list of conda environments on Amarel. This file should be located in the investigating_orthogroups folder. If you have never worked with CONDA on Amarel, please find directions [here](https://github.com/lizardroom/conda_on_amarel). 

```
conda env create -f orthofinder.yml
conda activate orthofinder # make sure that the environment installed properly
```

Once the OrthoFinder environment has been verified to work correctly and the fasta files are renamed accordingly, we can make a script that actually runs the program. This is the script below but it is also in the folder as `run_orthofinder.sh`. You may need to change the file paths. You will point this towards wherever you have put the changed FASTA files (ideally the `investigating_orthogroups` head directory).

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

echo "Create variables for Orthofinder"

cd ./investigating_orthogroups/

ulimit -n 2400

orthofinder -f investigating_orthogroups/ -M msa                  # Run full OrthoFinder analysis on FASTA format proteomes in specfied directory

# orthofinder [options] -f <dir1> -b <dir2>     # Add new species in to a previous run and run new analysis

```

OrthoFinder then will make a lot of files (!) in the same directory you sent the run off at. You actually don't need all the files. OrthoFinder makes a list of single copy orthologue sequences, which it associates with (from what I can tell) random but sequential numbers. Therefore, we need to take the list of single-copy orthologue sequences, and select those associated named gene trees from the gene trees file.


```
cd OrthoFinder/<YOUR_DATE_HERE>/MultipleSequenceAlignments

cat ../Orthogroups/Orthogroups_SingleCopyOrthologues.txt | xargs -n 1 -I {} cp {}.fa ../../../iqtree/

```

## IQTREE

So now you should have all of your orthologous gene groups (orthologues) that were the output of OrthoFinder, one in each file. Now we are going to make gene trees from these files - one each! We will use the program IQTree. We don't need to download IQTree since it is already downloaded and within the Geneva lab's shared applications. So, what we can do, is follow the instructions below to access shared modules.

To use shared modules you will need to run these two lines.

```
module use /projects/community/modulefiles
PATH=$PATH:/projects/f_geneva_1/.shared_apps/bin
```

Then you can test it by simply typing `iqtree` in the command line and it should pop up.

IQTree works by first running a simulation to select the best model of evolution for each orthogroup and then it creates a gene tree based on that model of evolution.

The syntax for an IQTree command is: 

```
iqtree -m TEST -s <YOUR_ORTHOGROUP_FILE>.fasta
```

The -m TEST flag means that we will be testing for the model of evolution.


Seen below is an individual slurm script for IQTree. This slurm script exists in the IQTREE folder.

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

However, there are 10 orthogroups (at least in my run) so it is kind of annoying to submit all 15 different jobs. Here we will make a loop file, called `run_loop_iqtree.sh` You will want to change the below information to be specific to your file paths on Amarel again. This file is also in the IQTREE folder.

```
for FILE in <YOUR_FILE_PATH_HERE>/investigating_orthogroups/iqtree/*.fasta; do
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

While that is running you can go back to the head directory and go into the ASTRAL directory.

```
cd astral
```


The output of IQTREE creates many things. It creates a tree file, which is what you need for Astral, and a Log file, which tells you what analysis was run and what the best model of evolution was. It can be important to look at both files, especially if you are interested in what model of evolution you need to use.

Tree files are the gene tree for that specific orthogroup in Newick format.


```
cat *.treefile > input_astral.tre

mv input_astral.tre ../astral
```


## ASTRAL

Astral is a Java-based program that is downloaded from a Zip file (link [here](https://github.com/smirarab/ASTRAL/raw/master/Astral.5.7.8.zip).)

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


Since we renamed the taxa already, we will rename them to the final names using the rename.sh script in the `astral` directory. This is optional but recommended.

```
./rename.sh
```

## Visualizing your results

We will visualize the tree using the program FigTree, which is a program you can download on your local machine. You can download this program [here](https://github.com/rambaut/figtree/releases). It may require also downloading the Java runtime environment.


Next, you will want to download your output tree onto your local machine. It should be called `output_tree.tre`. The file is basically a phylogenetic tree in a specialized format called the Newick Format that is readable by most phylogenetic tree programs. You can read more about Newick format [here](https://en.wikipedia.org/wiki/Newick_format).

1. Load the phylogenetic tree into Astral. Since it is a GUI you can just click `File>New` and navigate to where you have downloaded it.

2. The next thing you will want to do is reroot the tree. You can click to reroot the tree by highlighting the branch that leads to the outgroup and clicking `reroot`. Our outgroup is the White Sturgeon Adenovirus. You can also align the tip labels by checking the box, "Align Tip Labels."

3. You can then continue to play around with the options in FigTree to visualize your tree (font sizes, tip colors, etc.). However, the last thing you will do is save your tree, which you can do by clicking `File>Export PDF`.

An example of what it should look like is in the main folder called `final_tree.pdf`.
