## FDR correction is done by hemisphere. Need to combine hemis.

contrasts=(10 11 9 15)
group_copes=("SandCBavg" "CBavg" "Savg" "CB-S" "S-CB")
task=gonogo
thirdLevelDir=GroupResults/$task/thirdlevel-varied-12fwhm

sub=32k_fs_LR
hemi=lh
surfdir=$SUBJECTS_DIR/$sub/surf

for group_cope in ${group_copes[@]}; do
    for contrast in ${contrasts[@]}; do
      contrast=cope${contrast}
      
      LDir=$thirdLevelDir/$task.${group_cope}.lh.rfx/$contrast/con1
      LStat=$LDir/sig.mgh
      mris_convert -f $LStat $surfdir/lh.white $LDir/sig.lh.func.gii
      wb_command -metric-convert -to-nifti $LDir/sig.lh.func.gii $LDir/sig.lh.nii.gz

      RDir=$thirdLevelDir/$task.${group_cope}.rh.rfx/$contrast/con1
      RStat=$RDir/sig.mgh
      mris_convert -f $RStat $surfdir/rh.white $RDir/sig.rh.func.gii
      wb_command -metric-convert -to-nifti $RDir/sig.rh.func.gii $RDir/sig.rh.nii.gz

      LMask=$thirdLevelDir/$task.${group_cope}.lh.rfx/$contrast/mask.mgh
      mris_convert -f $LMask $surfdir/lh.white $LDir/mask.lh.func.gii
      wb_command -metric-convert -to-nifti $LDir/mask.lh.func.gii $LDir/mask.lh.nii.gz
    
      RMask=$thirdLevelDir/$task.${group_cope}.rh.rfx/$contrast/mask.mgh
      mris_convert -f $RMask $surfdir/rh.white $RDir/mask.rh.func.gii
      wb_command -metric-convert -to-nifti $RDir/mask.rh.func.gii $RDir/mask.rh.nii.gz

      fslmerge -y $LDir/sig.bl.nii.gz $LDir/sig.lh.nii.gz $RDir/sig.rh.nii.gz
      fslmerge -y $LDir/mask.bl.nii.gz $LDir/mask.lh.nii.gz $RDir/mask.rh.nii.gz

      fdr_corr --mask=$LDir/mask.bl.nii.gz logp $LDir/sig.bl.nii.gz $LDir/sig_fdr.bl.nii.gz > $LDir/fdr05_thresh_wb.txt

      cp $LDir/fdr05_thresh_wb.txt $RDir/fdr05_thresh_wb.txt

      fslsplit $LDir/sig_fdr.bl.nii.gz $LDir/sig_fdr -y
      wb_command -metric-convert -from-nifti $LDir/sig_fdr0000.nii.gz $GNGC/SurfAnat/32k_fs_LR/surf/lh.midthickness.surf.gii $LDir/sig_fdr_wb.func.gii
      wb_command -metric-convert -from-nifti $LDir/sig_fdr0001.nii.gz $GNGC/SurfAnat/32k_fs_LR/surf/rh.midthickness.surf.gii $RDir/sig_fdr_wb.func.gii       

      rm -r $LDir/sig_fdr0000.nii.gz $LDir/sig_fdr0001.nii.gz $LDir/sig_fdr.bl.nii.gz $LDir/sig.bl.nii.gz $LDir/mask.bl.nii.gz $LDir/sig.lh.nii.gz $RDir/sig.rh.nii.gz $LDir/mask.lh.nii.gz $RDir/mask.rh.nii.gz $LDir/sig.lh.func.gii $RDir/sig.rh.func.gii
 		
  done
done
