#!/bin/bash

# https://github.com/andikleen/pmu-tools
#Simple script to upload a new version of HPCCG-RHT to Grid 5K and run them
#chmod +x executable, to give permission

#Example of use: ./myScriptCOMD.sh CoMD-RHT

folder="$1"
newFolder="$1"-Clean

echo Folder Name: $folder $newFolder

cp -a $folder/ ./$newFolder
rm -rf $newFolder/.git
rm -rf $newFolder/.idea

#copying scripts to tempFolder
mkdir $newFolder/tempFolder
cp -a $newFolder/runNova.sh ./$newFolder/tempFolder
cp -a $newFolder/runEcotype.sh ./$newFolder/tempFolder
cp -a $newFolder/runEcotype-testHT.sh ./$newFolder/tempFolder

rm -rf $newFolder/cmake-build-debug

#renaming tempFolder to cmake-build-debug
mv $newFolder/tempFolder/ $newFolder/cmake-build-debug/

cp -r $newFolder/pots/ $newFolder/cmake-build-debug/

tar -czvf $newFolder.tar.gz $newFolder
rm -r -f $newFolder
echo "zip file created"

#echo "Copying files to Nancy..."
#scp $newFolder.tar.gz dperez@access.grid5000.fr:nancy/public
echo "Copying files to Nantes..."
scp $newFolder.tar.gz dperez@access.grid5000.fr:nantes/public
echo "Copying files to Lyon..."
scp $newFolder.tar.gz dperez@access.grid5000.fr:lyon/public
echo "Files copied to Grid5K Storage"
echo "Removing zip file"
rm $newFolder.tar.gz
echo "Success!!"

#rm -f -r nantes/public/CoMD-RHT-Clean/ && rm -f -r nancy/public/CoMD-RHT-Clean/

# Inside a node (if tar.gz was copied into public/ with appriate file structure)
#cd public/ && tar -xzvf CoMD-RHT-Clean.tar.gz && rm CoMD-RHT-Clean.tar.gz && cd CoMD-RHT-Clean/cmake-build-debug/ && cmake .. && make

#sudo-g5k && sudo -H /bin/bash 
#sudo echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list.d/preferences.list &&
#sudo echo "Package: *
#Pin: release a=testing
#Pin-Priority: 100" > /etc/apt/preferences.d/preferences.list && exit
#sudo apt-get update && sudo apt-get install -t testing g++

#nancy
#oarsub -p "cluster='graphite'" -I -l nodes=1,walltime=5

#nantes
#oarsub -p "cluster='econome'" -I -l nodes=1,walltime=5

#nantes
#oarsub -p "cluster='ecotype'" -I -l nodes=1,walltime=5

#lyon
#oarsub -p "cluster='nova'" -I -l nodes=1,walltime=5

#lille
#oarsub -p "cluster='chifflet'" -I -l nodes=1,walltime=1

#kill a job (check job id at grid5k website)
#oardel 12345

#connect to a job with id 12345
#oarsub -C 12345

#execute a script file
#oarsub -p "cluster='nova'" -l nodes=1,walltime=4 "/home/dperez/public/CoMD-RHT-Clean/cmake-build-debug/runNova.sh"

#oarsub -p "cluster='ecotype'" -l nodes=1,walltime=4 "/home/dperez/public/CoMD-RHT-Clean/cmake-build-debug/runEcotype.sh"

#lille
#oarsub -p "cluster='chifflet'" -l nodes=1,walltime=5 "/home/dperez/public/CoMD-RHT-Clean/cmake-build-debug/runChifflet.sh"

#ssh dperez@access.grid5000.fr

