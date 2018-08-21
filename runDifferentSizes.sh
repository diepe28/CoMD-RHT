#!/bin/bash

# https://github.com/andikleen/pmu-tools
#Simple script to upload a new version of HPCCG-RHT to Grid 5K and run them
#chmod +x executable, to give permission

nRuns=10
nRanks=20
nCores=40
coresHT="0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39"

x=80
y=80
z=80

echo Problem size 1
mpirun -np $nRanks CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns > 0-baseline1.txt
mpirun -np $nRanks IMP-CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 1-replicated1.txt

x=85
y=85
z=85

echo Problem size 2
mpirun -np $nRanks CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns > 2-baseline2.txt
mpirun -np $nRanks IMP-CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 3-replicated2.txt

x=90
y=90
z=90

echo Problem size 3
mpirun -np $nRanks CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns > 4-baseline3.txt
mpirun -np $nRanks IMP-CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 5-replicated3.txt

x=95
y=95
z=95

echo Problem size 4
mpirun -np $nRanks CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns > 6-baseline4.txt
mpirun -np $nRanks IMP-CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 7-replicated4.txt

x=100
y=100
z=100

echo Problem size 5
mpirun -np $nRanks CoMD-WANG -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns > 8-baseline5.txt
mpirun -np $nRanks IMP-CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x $x -y $y -z $z $nRuns $nCores $coresHT > 9-replicated5.txt
