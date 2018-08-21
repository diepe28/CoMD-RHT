#!/bin/bash

# https://github.com/andikleen/pmu-tools
#Simple script to upload a new version of HPCCG-RHT to Grid 5K and run them
#chmod +x executable, to give permission

#sudo-g5k
#sudo apt-get install msr-tools
#sudo modprobe msr
#
#echo Printing values
#for cpu in {0..19}; do sudo /usr/sbin/rdmsr -p$cpu 0x1a0 -f 38:38; done
#
#echo Disabling turbo-mode
#for cpu in {0..19}; do sudo /usr/sbin/wrmsr -p$cpu 0x1a0 0x4000850089; do$
#
#echo Printing values
#for cpu in {0..19}; do sudo /usr/sbin/rdmsr -p$cpu 0x1a0 -f 38:38; done
#
#echo Done disabling turbo-mode

x=150
y=150
z=150
nRuns=10
nRanks=20
nCores=40

echo Running baseline 1 rank
mpirun -np 1 CoMD-WANG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns > baseline-1rank.txt
mpirun -np 2 CoMD-WANG -e -i 2 -j 1 -k 1 -x $x -y $y -z $z $nRuns > baseline-2rank.txt
mpirun -np 4 CoMD-WANG -e -i 2 -j 2 -k 1 -x $x -y $y -z $z $nRuns > baseline-4rank.txt
mpirun -np 8 CoMD-WANG -e -i 2 -j 2 -k 2 -x $x -y $y -z $z $nRuns > baseline-8rank.txt
mpirun -np 16 CoMD-WANG -e -i 4 -j 2 -k 2 -x $x -y $y -z $z $nRuns > baseline-16rank.txt
mpirun -np 20 CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns > baseline-20rank.txt
mpirun -np 40 CoMD-WANG -e -i 5 -j 4 -k 2 -x $x -y $y -z $z $nRuns > baseline-40rank.txt


