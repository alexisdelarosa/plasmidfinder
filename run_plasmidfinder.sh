#!/bin/bash

#This script extracts multiple fasta files, analyses them with plasmid finder, converts text files into tab-separated ones, and merges results 
#Run this script from folder plasmid finder

#STEP 1 (Before Running this script)
#Obtain multiple fasta files from https://www.ncbi.nlm.nih.gov/nuccore/advanced
#Place downloaded file sequence.fasta into folder plasmidfinder
#Have programs all2many.pl and fasta_to_tsv.py in folder plasmidfinder

#STEP 2 (Before Running this script)
#Make sure your ncbi blast folder is on your desktop (check that the correct path to blastn is inputted after -mp below (line 27))

#Extracting multiple fasta files from sequence.fasta
#Files are extracted as GenbankAccession.fa
start=$(date)
perl all2many.pl sequence.fasta 1

mkdir -p tmp
mkdir -p ~/Desktop/plasmidfinder_results

#Running resfinder.py and fasta_to_tsv.py
for folder in $(ls *.fa)
do
  isolates=${folder%%.fa*}
  mkdir ~/Desktop/plasmidfinder_results/$isolates
  python3 plasmidfinder.py -i $folder -o ~/Desktop/plasmidfinder_results/$isolates -p plasmidfinder_db -mp ~/Desktop/ncbi-blast-2.11.0+/bin/blastn -l 0.6 -t 0.95 -tmp tmp -x -q
  python3 fasta_to_tsv.py ~/Desktop/plasmidfinder_results/$isolates/Hit_in_genome_seq.fsa
  mv results.tsv ~/Desktop/plasmidfinder_results/$isolates
  echo "$isolates is done"
done

#Adding line 'no hit found' to results_tab.tsv, when necessary
#Adding empty line to results.tsv, when necessary
cd ~/Desktop/plasmidfinder_results
for gb_accession in $(ls ~/Desktop/plasmidfinder_results)
do
    read nlines filename <<< $(wc -l $gb_accession/results_tab.tsv)
    if [ $nlines -eq 1 ]
    then
        echo "Acession $gb_accession does not have mutations, line will be added"
        echo "No hit found" >> $gb_accession/results_tab.tsv
        echo $'' >> $gb_accession/results.tsv   #adds empty line to the end of file
    fi
done

#Merging individual files into one for G-drive database
cd ~/Desktop/plasmidfinder_results  
for files in $(ls ~/Desktop/plasmidfinder_results)
do 
  cat $files/results_tab.tsv >> merged_results_tab.tsv
  cat $files/results.tsv >> merged_results.tsv

  num_lines=$(cat ~/Desktop/plasmidfinder_results/$files/results_tab.tsv | wc -l)
  echo "Number of lines in individual file $files : $num_lines"
  for ((i=1; i<="$num_lines"; i++))
  do
    echo "$files" >> merged_GBlines.txt
  done
done

read nl1 filename1 <<< $(wc -l merged_GBlines.txt)
read nl2 filename2 <<< $(wc -l merged_results_tab.tsv)
read nl3 filename3 <<< $(wc -l merged_results.tsv)

echo 
echo "PlasmidFinder check-up:"
echo "$nl1 lines in merged_GBlines.txt"
echo "$nl2 lines in merged_results_tab.tsv"
echo "$nl3 lines in merged_results.tsv"

paste merged_GBlines.txt merged_results_tab.tsv merged_results.tsv > pf_merged_done.tsv
dataset_nl=$(cat ./pf_merged_done.tsv | wc -l)
end=$(date)
echo "Started run at $start"
echo "Finished run at $end"
echo
echo "Use file pf_merged_done.tsv in plasmidfinder_results"
echo "You will need $dataset_nl lines in G-drive to fit data in pf_merged_done.tsv"

