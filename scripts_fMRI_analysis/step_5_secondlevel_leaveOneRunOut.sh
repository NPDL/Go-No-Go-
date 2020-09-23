log=./secondlevel_L1RO.log
job=./secondlevel-L1RO.txt
rm $job $log

subjects=( GNGC_S_01 GNGC_S_02 )

task=gonogo
mainDir=${task}
suffix=-varied-6fwhm
firstlevelDir=${mainDir}/firstlevel${suffix}
secondlevelDir=${mainDir}/secondlevel_LOO${suffix}

for s in "${subjects[@]}"; do
  
  outDirName=$s/$secondlevelDir
  
  if [ -d "$outDirName" ]; then
    rm -r $outDirName
  fi
  
  mkdir -p $outDirName
  
  for hemi in lh rh; do
    
    for j in `seq 1 3`; do
      
      if [ "$j" -eq "1" ]; then
        
        # Note that this won't work well if a participant is missing a run, but none of these participants are
	      allruns=`echo $s/$firstlevelDir/${task}_02.$hemi.glm $s/$firstlevelDir/${task}_03.$hemi.glm`
      
      elif [ "$j" -eq "2" ]; then
	      
        allruns=`echo $s/$firstlevelDir/${task}_01.$hemi.glm $s/$firstlevelDir/${task}_03.$hemi.glm`
      
      elif [ "$j" -eq "3" ]; then
	    
        allruns=`echo $s/$firstlevelDir/${task}_01.$hemi.glm $s/$firstlevelDir/${task}_02.$hemi.glm`
      fi
      
      outdir=$outDirName/${task}-0$j.$hemi.ffx
      
      echo "fixedfx --log $log $hemi $outdir ${allruns[@]}" >> $job
    
    done
  done
done

echo "parallel -j 20 < $job"

