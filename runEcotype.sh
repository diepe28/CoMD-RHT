#!/bin/bash

# https://github.com/andikleen/pmu-tools
#Simple script to upload a new version of HPCCG-RHT to Grid 5K and run them
#chmod +x executable, to give permission

#sudo-g5k
#sudo apt-get install msr-tools
#sudo modprobe msr

#echo Printing values
#for cpu in {0..19}; do sudo /usr/sbin/rdmsr -p$cpu 0x1a0 -f 38:38; done

#echo Disabling turbo-mode
#for cpu in {0..19}; do sudo /usr/sbin/wrmsr -p$cpu 0x1a0 0x4000850089; do$

#echo Printing values
#for cpu in {0..19}; do sudo /usr/sbin/rdmsr -p$cpu 0x1a0 -f 38:38; done

#echo Done disabling turbo-mode

x=30
y=30
z=30
nRuns=10
nRanks=1
nCores=2
coresNOHT="0 2"
coresHT="0 20"

echo Running baseline 1 rank
mpirun -np $nRanks CoMD-WANG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns > 0-baseline-1rank.txt

echo Running replicated wang 1rank noHT
mpirun -np $nRanks CoMD-WANG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresHT> 1-replicated-wang-1rank-HT.txt
mpirun -np $nRanks IMP-CoMD-WANG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresHT> 2-IMP-replicated-wang-1rank-HT.txt

echo Running replicated wang 1 rank HT
mpirun -np $nRanks CoMD-WANG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresNOHT> 3-replicated-wang-1rank-noHT.txt
mpirun -np $nRanks IMP-CoMD-WANG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresNOHT> 4-IMP-replicated-wang-1rank-noHT.txt

echo Running replicated wang with var grouping 1 rank noHT
mpirun -np $nRanks CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresHT> 5-replicated-wang-vg-1rank-HT.txt
mpirun -np $nRanks IMP-CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresHT> 6-IMP-replicated-wang-vg-1rank-HT.txt

echo Running replicated wang with var grouping 1 rank HT
mpirun -np $nRanks CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresNOHT> 7-replicated-wang-vg-1rank-noHT.txt
mpirun -np $nRanks IMP-CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresNOHT> 8-IMP-replicated-wang-vg-1rank-noHT.txt

echo Running replicated wang just volatiles 1 rank noHT
mpirun -np $nRanks CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresHT> 9-replicated-wang-jv-1rank-HT.txt
mpirun -np $nRanks IMP-CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresHT> 10-IMP-replicated-wang-jv-1rank-HT.txt

echo Running replicated wang just volatiles 1 rank HT
mpirun -np $nRanks CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresNOHT> 11-replicated-wang-jv-1rank-noHT.txt
mpirun -np $nRanks IMP-CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x $x -y $y -z $z $nRuns $nCores $coresNOHT> 12-IMP-replicated-wang-jv-1rank-noHT.txt


x=80
y=80
z=80
nRanks=20
nCores=40
coresNOHT="0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39"
coresHT="0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39"

echo Running baseline 20 ranks
mpirun -np $nRanks CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns > 13-mybaseline-20rank.txt

echo Running replicated wang 20 rank noHT
mpirun -np $nRanks CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresNOHT > 14-replicated-wang-20rank-noHT.txt
mpirun -np $nRanks IMP-CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresNOHT > 15-IMP-replicated-wang-20rank-noHT.txt

echo Running replicated wang 20 rank HT
mpirun -np $nRanks CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 16-replicated-wang-20rank-HT.txt
mpirun -np $nRanks IMP-CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 17-IMP-replicated-wang-20rank-HT.txt

echo Running replicated wang with var grouping 20 rank noHT
mpirun -np $nRanks CoMD-WANG-VG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresNOHT > 18-replicated-wang-vg-20rank-noHT.txt
mpirun -np $nRanks IMP-CoMD-WANG-VG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresNOHT > 19-IMP-replicated-wang-vg-20rank-noHT.txt

echo Running replicated wang with var grouping 20 rank HT
mpirun -np $nRanks CoMD-WANG-VG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 20-replicated-wang-vg-20rank-HT.txt
mpirun -np $nRanks IMP-CoMD-WANG-VG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 21-IMP-replicated-wang-vg-20rank-HT.txt

echo Running replicated wang just volatiles grouping 20 ranks noHT
mpirun -np $nRanks CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresNOHT > 22-replicated-wang-jv-20rank-noHT.txt
mpirun -np $nRanks IMP-CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresNOHT > 23-IMP-replicated-wang-jv-20rank-noHT.txt

echo Running replicated wang just volatiles grouping 20 ranks HT
mpirun -np $nRanks CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 24-replicated-wang-jv-20rank-HT.txt    
mpirun -np $nRanks IMP-CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 25-IMP-replicated-wang-jv-20rank-HT.txt
