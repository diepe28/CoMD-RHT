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

echo Running replicated wang 20 rank HT
mpirun -np 20 CoMD-WANG -e -i 5 -j 2 -k 2 -x 80 -y 80 -z 80 10 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > 1-replicated-wang-HT.txt

echo Running replicated wang with var grouping 2 20 rank HT
mpirun -np 20 CoMD-WANG-VG-2 -e -i 5 -j 2 -k 2 -x 80 -y 80 -z 80 10 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > 2-replicated-wang-vg-2.txt

echo Running replicated wang with var grouping 4 20 rank HT
mpirun -np 20 CoMD-WANG-VG-4 -e -i 5 -j 2 -k 2 -x 80 -y 80 -z 80 10 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > 3-replicated-wang-vg-4.txt

echo Running replicated wang with var grouping 8 20 rank HT
mpirun -np 20 CoMD-WANG-VG-8 -e -i 5 -j 2 -k 2 -x 80 -y 80 -z 80 10 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > 4-replicated-wang-vg-8.txt

echo Running replicated wang with var grouping 16 20 rank HT
mpirun -np 20 CoMD-WANG-VG-16 -e -i 5 -j 2 -k 2 -x 80 -y 80 -z 80 10 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > 5-replicated-wang-vg-16.txt

echo Running replicated wang with var grouping 32 20 rank HT
mpirun -np 20 CoMD-WANG-VG-32 -e -i 5 -j 2 -k 2 -x 80 -y 80 -z 80 10 40 0 20 2 22 4 24 6 26 8 28 10 30 12 32 14 34 16 36 18 38 1 21 3 23 5 25 7 27 9 29 11 31 13 33 15 35 17 37 19 39 > 6-replicated-wang-vg-32.txt


