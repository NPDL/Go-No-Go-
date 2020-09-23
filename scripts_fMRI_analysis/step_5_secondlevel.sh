log=./jobs/secondlevel.log
job=./jobs/secondlevel.txt
rm $job $log

subjects=(GNGC_S_01 GNGC_S_02)

task=gonogo
mainDir=${task}

#---12mm for group level statistics
#suffix=-varied-12fwhm

#---6mm for ROI analysis
suffix=-varied-6fwhm

firstlevelDir=${mainDir}/firstlevel${suffix}
secondlevelDir=${mainDir}/secondlevel${suffix}

for s in "${subjects[@]}"; do
  
  outDirName=$s/$secondlevelDir
  
  if [ -d "$outDirName" ]; then
    rm -r $outDirName
  fi
  
  mkdir -p $outDirName
  
  for hemi in lh rh; do
    
    allruns=`echo $s/$firstlevelDir/${task}_0[1-3].$hemi.glm`
    
    numRuns=`echo ${allruns[@]} | wc -w`
    
    if [ "$numRuns" -ne "3" ]; then
      echo "$s has fewer than 3 first level runs"
    fi
    
    outdir=$outDirName/${task}.$hemi.ffx
    
    echo "fixedfx --log $log $hemi $outdir ${allruns[@]}" >> $job
  
  done
done

echo "parallel -j 20 < $job"

