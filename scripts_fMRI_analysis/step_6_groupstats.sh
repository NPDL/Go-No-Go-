subs_S=(GNGC_S_01 GNGC_S_02 GNGC_S_04 GNGC_S_05 GNGC_S_06 GNGC_S_07 GNGC_S_08 GNGC_S_09 GNGC_S_10 GNGC_S_11 GNGC_S_12 GNGC_S_13 GNGC_S_14 GNGC_S_15 GNGC_S_16 GNGC_S_17 GNGC_S_18 GNGC_S_19 GNGC_S_20 GNGC_S_21 GNGC_S_22 GNGC_S_23 GNGC_S_24 GNGC_S_27)

subs_CB=(GNGC_CB_02 GNGC_CB_03 GNGC_CB_04 GNGC_CB_05 GNGC_CB_06 GNGC_CB_07 GNGC_CB_08 GNGC_CB_09 GNGC_CB_10 GNGC_CB_11 GNGC_CB_12 GNGC_CB_13 GNGC_CB_14 GNGC_CB_15 GNGC_CB_16 GNGC_CB_17 GNGC_CB_18 GNGC_CB_19 GNGC_CB_20 GNGC_CB_21 GNGC_CB_23 GNGC_CB_24 GNGC_CB_25)

subs_SandCB=("${subs_S[@]}" "${subs_CB[@]}")

task=gonogo
analysis_folder=$task
groupout=GroupResults/${analysis_folder}/thirdlevel-varied-12fwhm
secondlevelDir=${analysis_folder}/secondlevel-varied-12fwhm

if [ -d "$groupout" ]; then
    rm -r $groupout
fi
mkdir -p $groupout

job=./jobs/thirdlevel.txt
log=./jobs/thirdlevel.log
rm -r $job $log

## Average of all Groups
for grp in CBavg Savg SandCBavg; do
  
  if [[ $grp == CBavg ]]; then
    subs=("${subs_CB[@]}")
  elif [[ $grp == Savg ]]; then
    subs=("${subs_S[@]}")
  elif [[ $grp == SandCBavg ]]; then
    subs=("${subs_SandCB[@]}")
  fi
  
  for hemi in lh rh; do
    
    Nsubs=${#subs[@]}
    
    design=./design_files/Group_${grp}_rfx_${Nsubs}.mat
    
    con=./design_files/Group_${grp}_rfx_${Nsubs}.mtx
    
    rm $design $con >/dev/null 2>&1 
    
    ffxdirs=
    for sub in ${subs[@]}; do
      echo 1 >> $design
      ffxdirs="$ffxdirs $sub/$secondlevelDir/$task.$hemi.ffx"
    done 
    
    echo 1 >> $con
    
    thirdlevel=$groupout/${task}.${grp}.$hemi.rfx			
    
    echo "groupstats --dil 10 --log $log $hemi $design $con $thirdlevel $ffxdirs" >> $job 
  done
done


for grp in "CB-S"; do
  
  for hemi in lh rh; do
   
    design=./design_files/Group_${grp}_rfx.mat
    
    con=./design_files/Group_${grp}_rfx.mtx
    
    rm $design $con >/dev/null 2>&1 
    
    subs=("${subs_CB[@]}")
    
    ffxdirs=
    for sub in ${subs[@]}; do
      echo "1 0" >> $design
      ffxdirs="$ffxdirs $sub/$secondlevelDir/$task.$hemi.ffx"
    done 
    
    subs=("${subs_S[@]}")
    for sub in ${subs[@]}; do
      echo "0 1" >> $design
      ffxdirs="$ffxdirs $sub/$secondlevelDir/$task.$hemi.ffx"
    done 
    
    echo "1 -1" >> $con
    
    thirdlevel=$groupout/${task}.${grp}.$hemi.rfx			
    
    echo "groupstats --dil 10 --log $log $hemi $design $con $thirdlevel $ffxdirs" >> $job
  
  done 
done

for grp in "S-CB"; do
  
  for hemi in lh rh; do
    
    design=./design_files/Group_${grp}_rfx.mat
    
    con=./design_files/Group_${grp}_rfx.mtx
    
    rm $design $con >/dev/null 2>&1 
    
    subs=("${subs_CB[@]}")
    
    ffxdirs=
    for sub in ${subs[@]}; do
      echo "1 0" >> $design
      ffxdirs="$ffxdirs $sub/$secondlevelDir/$task.$hemi.ffx"
    done 
    
    subs=("${subs_S[@]}")
    for sub in ${subs[@]}; do
      echo "0 1" >> $design
      ffxdirs="$ffxdirs $sub/$secondlevelDir/$task.$hemi.ffx"
    done 
    
    echo "-1 1" >> $con
    
    thirdlevel=$groupout/${task}.${grp}.$hemi.rfx			
    
    echo "groupstats --dil 10 --log $log $hemi $design $con $thirdlevel $ffxdirs" >> $job 
  
  done
done
 
