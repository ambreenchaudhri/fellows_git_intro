#!/bin/bash

clear

# activate conda environment
#moduel load python/anaconda3.6
#source activate automate_env

# load modules
module load python/anaconda3.6
module load R/4.0.3

# Run python script
python 1_fec_extract.py

# only run next step if file exists
{
if [ ! -f ~/2_automation/FEC/weball20.txt ]; then
    echo "File not found!"
    exit 0
fi
}

# Run R script
Rscript 2_fec_process.R

