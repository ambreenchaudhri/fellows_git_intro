#!/bin/bash -l

source ~/.bash_profile
module load python/anaconda3.6
python ~/2_automation/FEC/1_fec_extract.py
echo "Cron Job is running on KLC Node 4."

