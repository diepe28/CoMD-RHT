#!/bin/bash

# https://github.com/andikleen/pmu-tools
#Simple script to upload a new version of HPCCG-RHT to Grid 5K and run them
#chmod +x executable, to give permission
#lstopo
#NUMA0   0,28    2,30    4,32    6,34    8,36    10,38   12,40   14,42   16,44   18,46   20,48   22,50   24,52   26,54
#NUMA1   1,29    3,31    5,33    7,35    9,37    11,39   13,41   15,43   17,45   19,47   21,49   23,51   25,53   27,55   

echo Running baseline 1 rank
mpirun -np 1 CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 > baseline-1rank.txt

echo Running replicated wang 1rank noHT
mpirun -np 1 CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 28 > replicated-wang-1rank-HT.txt
mpirun -np 1 IMP-CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 28 > IMP-replicated-wang-1rank-HT.txt

echo Running replicated wang 1 rank HT
mpirun -np 1 CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > replicated-wang-1rank-noHT.txt
mpirun -np 1 IMP-CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > IMP-replicated-wang-1rank-noHT.txt

echo Running replicated wang with var grouping 1 rank noHT
mpirun -np 1 CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 28 > replicated-wang-vg-1rank-HT.txt
mpirun -np 1 IMP-CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 28 > IMP-replicated-wang-vg-1rank-HT.txt

echo Running replicated wang with var grouping 1 rank HT
mpirun -np 1 CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > replicated-wang-vg-1rank-noHT.txt
mpirun -np 1 IMP-CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > IMP-replicated-wang-vg-1rank-noHT.txt

echo Running replicated wang just volatiles 1 rank noHT
mpirun -np 1 CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 28 > replicated-wang-jv-1rank-HT.txt
mpirun -np 1 IMP-CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 28 > IMP-replicated-wang-jv-1rank-HT.txt

echo Running replicated wang just volatiles 1 rank HT
mpirun -np 1 CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > replicated-wang-jv-1rank-noHT.txt
mpirun -np 1 IMP-CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > IMP-replicated-wang-jv-1rank-noHT.txt

echo Running baseline 20 ranks
mpirun -np 28 CoMD-WANG -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 > mybaseline-28rank.txt

echo Running replicated wang 20 rank noHT
mpirun -np 28 CoMD-WANG -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 > replicated-wang-28rank-noHT.txt
mpirun -np 28 IMP-CoMD-WANG -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 > IMP-replicated-wang-28rank-noHT.txt

echo Running replicated wang 20 rank HT
mpirun -np 28 CoMD-WANG -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 28 2 30 4 32 6 34 8 36 10 38 12 40 14 42 16 44 18 46 20 48 22 50 24 52 26 54 1 29 3 31 5 33 7 35 9 37 11 39 13 41 15 43 17 45 19 47 21 49 23 51 25 53 27 55 > replicated-wang-28rank-HT.txt
mpirun -np 28 IMP-CoMD-WANG -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 28 2 30 4 32 6 34 8 36 10 38 12 40 14 42 16 44 18 46 20 48 22 50 24 52 26 54 1 29 3 31 5 33 7 35 9 37 11 39 13 41 15 43 17 45 19 47 21 49 23 51 25 53 27 55 > IMP-replicated-wang-28rank-HT.txt

echo Running replicated wang with var grouping 20 rank noHT
mpirun -np 28 CoMD-WANG-VG -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 > replicated-wang-vg-28rank-noHT.txt
mpirun -np 28 IMP-CoMD-WANG-VG -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 > IMP-replicated-wang-vg-28rank-noHT.txt

echo Running replicated wang with var grouping 20 rank HT
mpirun -np 28 CoMD-WANG-VG -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 28 2 30 4 32 6 34 8 36 10 38 12 40 14 42 16 44 18 46 20 48 22 50 24 52 26 54 1 29 3 31 5 33 7 35 9 37 11 39 13 41 15 43 17 45 19 47 21 49 23 51 25 53 27 55 > replicated-wang-vg-28rank-HT.txt
mpirun -np 28 IMP-CoMD-WANG-VG -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 28 2 30 4 32 6 34 8 36 10 38 12 40 14 42 16 44 18 46 20 48 22 50 24 52 26 54 1 29 3 31 5 33 7 35 9 37 11 39 13 41 15 43 17 45 19 47 21 49 23 51 25 53 27 55 > IMP-replicated-wang-vg-28rank-HT.txt

echo Running replicated wang just volatiles grouping 20 ranks noHT
mpirun -np 28 CoMD-WANG-JV -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 > replicated-wang-jv-28rank-noHT.txt
mpirun -np 28 IMP-CoMD-WANG-JV -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 > IMP-replicated-wang-jv-28rank-noHT.txt

echo Running replicated wang just volatiles grouping 20 ranks HT
mpirun -np 28 CoMD-WANG-JV -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 28 2 30 4 32 6 34 8 36 10 38 12 40 14 42 16 44 18 46 20 48 22 50 24 52 26 54 1 29 3 31 5 33 7 35 9 37 11 39 13 41 15 43 17 45 19 47 21 49 23 51 25 53 27 55 > replicated-wang-jv-28rank-HT.txt    
mpirun -np 28 IMP-CoMD-WANG-JV -e -i 7 -j 2 -k 2 -x 110 -y 110 -z 110 5 56 0 28 2 30 4 32 6 34 8 36 10 38 12 40 14 42 16 44 18 46 20 48 22 50 24 52 26 54 1 29 3 31 5 33 7 35 9 37 11 39 13 41 15 43 17 45 19 47 21 49 23 51 25 53 27 55 > IMP-replicated-wang-jv-28rank-HT.txt    
