#!/bin/bash

#This script is made to install plasmid finder
#make sure BLAST is  already installed and path is added

#Install cgecore and tabulate, possibly already installed
pip3 install cgecore
pip3 install tabulate


#Install plasmid finder and databases
git clone https://bitbucket.org/genomicepidemiology/plasmidfinder.git ~/Desktop/plasmidfinder
git clone https://bitbucket.org/genomicepidemiology/plasmidfinder_db.git plasmidfinder/plasmidfinder_db
git clone https://bitbucket.org/genomicepidemiology/kma.git plasmidfinder/plasmidfinder_db/kma
cd plasmidfinder/plasmidfinder_db/kma && make
cd ..
python3 INSTALL.py ./kma/kma_index
