#Please make sure you are using Go-NoGo Branch of NPDL Scripts

subs=(GNGC_S_01 GNGC_S_02)

task=gonogo
fold=$task-28Dec18

job=./jobs/preproc.txt
log=./jobs/preproc.log
rm $job $log 2>/dev/null

for sub in ${subs[@]}; do
	
  for run in $sub/raw/${task}_[0][1-3].nii.gz; do
		
    runname=`basename ${run%.nii.gz}`
		
    preprocDir=$sub/$fold/preproc
    
    if [ -d "$preprocDir" ]; then
      rm -r $preprocDir
    fi
	  
    mkdir -p $preprocDir               
		
    echo "preproc --log $log --slice u $sub $run ${preprocDir}/$runname" >> $job
	
  done
done

echo "parallel -j 15 < $job"
