#!/bin/bash

# https://github.com/andikleen/pmu-tools
#Simple script to upload a new version of HPCCG-RHT to Grid 5K and run them
#chmod +x executable, to give permission

echo Running baseline 1 rank
mpirun -np 1 CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 > baseline-1rank.txt

echo Running replicated wang 1rank noHT
mpirun -np 1 CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 20 > replicated-wang-1rank-HT.txt
mpirun -np 1 IMP-CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 20 > IMP-replicated-wang-1rank-HT.txt

echo Running replicated wang 1 rank HT
mpirun -np 1 CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > replicated-wang-1rank-noHT.txt
mpirun -np 1 IMP-CoMD-WANG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > IMP-replicated-wang-1rank-noHT.txt

echo Running replicated wang with var grouping 1 rank noHT
mpirun -np 1 CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 16 > replicated-wang-vg-1rank-HT.txt
mpirun -np 1 IMP-CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 16 > IMP-replicated-wang-vg-1rank-HT.txt

echo Running replicated wang with var grouping 1 rank HT
mpirun -np 1 CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > replicated-wang-vg-1rank-noHT.txt
mpirun -np 1 IMP-CoMD-WANG-VG -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > IMP-replicated-wang-vg-1rank-noHT.txt

echo Running replicated wang just volatiles 1 rank noHT
mpirun -np 1 CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 16 > replicated-wang-jv-1rank-HT.txt
mpirun -np 1 IMP-CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 16 > IMP-replicated-wang-jv-1rank-HT.txt

echo Running replicated wang just volatiles 1 rank HT
mpirun -np 1 CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > replicated-wang-jv-1rank-noHT.txt
mpirun -np 1 IMP-CoMD-WANG-JV -e -i 1 -j 1 -k 1 -x 30 -y 30 -z 30 5 2 0 2 > IMP-replicated-wang-jv-1rank-noHT.txt

echo Running baseline 20 ranks
mpirun -np 20 CoMD-WANG -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 > mybaseline-20rank.txt

echo Running replicated wang 20 rank noHT
mpirun -np 20 CoMD-WANG -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 > replicated-wang-20rank-noHT.txt
mpirun -np 20 IMP-CoMD-WANG -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 > IMP-replicated-wang-20rank-noHT.txt

echo Running replicated wang 20 rank HT
mpirun -np 20 CoMD-WANG -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > replicated-wang-20rank-HT.txt
mpirun -np 20 IMP-CoMD-WANG -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > IMP-replicated-wang-20rank-HT.txt

echo Running replicated wang with var grouping 20 rank noHT
mpirun -np 20 CoMD-WANG-VG -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 > replicated-wang-vg-20rank-noHT.txt
mpirun -np 20 IMP-CoMD-WANG-VG -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 > IMP-replicated-wang-vg-20rank-noHT.txt

echo Running replicated wang with var grouping 20 rank HT
mpirun -np 20 CoMD-WANG-VG -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > replicated-wang-vg-20rank-HT.txt
mpirun -np 20 IMP-CoMD-WANG-VG -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > IMP-replicated-wang-vg-20rank-HT.txt

echo Running replicated wang just volatiles grouping 20 ranks noHT
mpirun -np 20 CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 > replicated-wang-jv-20rank-noHT.txt
mpirun -np 20 IMP-CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 > IMP-replicated-wang-jv-20rank-noHT.txt

echo Running replicated wang just volatiles grouping 20 ranks HT
mpirun -np 20 CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > replicated-wang-jv-20rank-HT.txt    
mpirun -np 20 IMP-CoMD-WANG-JV -e -i 5 -j 2 -k 2 -x 70 -y 70 -z 70 5 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > IMP-replicated-wang-jv-20rank-HT.txt    
