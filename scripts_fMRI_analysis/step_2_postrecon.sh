#Please make sure you are using Go-NoGo Branch of NPDL Scripts

subs=(GNGC_S_01 GNGC_S_02)

job=./jobs/post-recon.txt
#rm -r $job

for SUBJID in ${subs[@]}; do
  echo "rm -r SurfAnat/$SUBJID/mri/T1.nii.gz; mv SurfAnat/$SUBJID/mri/T1.nii SurfAnat/$SUBJID/mri/T1-temp.nii; postrecon $SUBJID; mv SurfAnat/$SUBJID/mri/T1-temp.nii SurfAnat/$SUBJID/mri/T1.nii " >> $job
done

echo "parallel -j 20 < $job"
