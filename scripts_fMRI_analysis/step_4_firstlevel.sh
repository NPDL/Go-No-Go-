subjects=(GNGC_S_01 GNGC_S_02)

task=gonogo
design=gonogo.fsf
mainDir=${task}
preprocDir=${mainDir}/preproc

log=./jobs/firstlevel.log
job=./jobs/firstlevel.txt

# design file does not include temporal derivatives of regressors
# added motion spikes to model, but not relative motion regressors
# did not add white matter or csf mean signal regressors
# using 12 mm fwhm smoothing for group analyses
# using 6 mm fwhm smoothing for within subject (e.g. ROI) analyses

designFile=./design_files/gonogo_design.fsf
cfds="fdrms" 

#---12mm smoothing for group level statistics
#firstlevelDir=firstlevel-varied-12fwhm 
#fwhm=11.8322

#---6mm smoothing for ROI analysis
firstlevelDir=firstlevel-varied-6fwhm 
fwhm=5.656854249


timingDir=./timing_files

rm $job $log

for s in "${subjects[@]}"; do
  
  outDirName=$s/${mainDir}/${firstlevelDir}
  
  if [ -d "$outDirName" ]; then
    rm -r $outDirName
  fi
  
  mkdir -p $outDirName
  
  for run in $s/$preprocDir/${task}_0?.feat; do
  
    name=`basename ${run%.feat}`
    
    evs=`echo $timingDir/${s}-${name}-*.txt`
    
    # Fetch list of confound covariates.
    cfdfs=
    for cfd in $cfds; do
      
      # Covariates assumed to be in art folder, within preprocessed output dir.
      cfdf=$run/art/$cfd.confound.txt
      
      # Add the file to the list of confounds if it exists.
      # NOTE: confound list separated by commas.
      if [[ -f $cfdf ]]; then
        cfdfs="$cfdfs,$cfdf"
      fi
    
    done
    
    # Trim off leading space.
    cfdfs=${cfdfs:1}
    
    for hemi in lh rh; do
      data=$run/$hemi.32k_fs_LR.surfed_data.func.gii
      surf=SurfAnat/$s/surf/$hemi.32k_fs_LR.midthickness.surf.gii
      outdir=$outDirName/$name.$hemi.glm
      
      if [ -z "$cfdfs" ]; then  # if empty confounds
        echo "firstlevel --fwhm $fwhm --log $log $data $surf $designFile \"$evs\" $outdir" >> $job
      else
        echo "firstlevel --cfd $cfdfs --fwhm $fwhm --log $log $data $surf $designFile \"$evs\" $outdir" >> $job
     fi

    done
  done
done		

echo "parallel -j 15 < $job"
