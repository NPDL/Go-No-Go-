jobfile=./jobs/roi_analysis.txt
if [ -e "$jobfile" ]; then
    rm $jobfile
fi

task=gonogo
mainDir=${task}
suffix=-varied-6fwhm
firstlevel=${mainDir}/firstlevel${suffix}
secondlevel=${mainDir}/secondlevel${suffix}
secondlevelLOO=${mainDir}/secondlevel_LOO${suffix}

top_num=20
is_percent=1

if [[ $is_percent == 0 ]]; then
	
  outName=ROI_Summary${suffix}-top${top_num}-vertices.csv
	
  subROI_dir=${mainDir}/roi${suffix}-top${top_num}-vertices  
  # These will get overwritten with each new analysis, so may want to move before running

else
	
  outName=ROI_Summary${suffix}-top${top_num}-percent.csv
  subROI_dir=${mainDir}/roi${suffix}-top${top_num}-percent  
  # These will get overwritten with each new analysis, so may want to move before running

fi

conds=(FG IG NG)

copeStats=(1 3 5) # note that pe numbers might not match contrast numbers. check design matrix

# for rois, you need to use nifti converted surface files
# rois need to be binarized or will weight the Beta values
rois=(ROIs/gonogo/PFC_RI.hemiReplace.nii.gz ROIs/gonogo/PFC_RI_and_Lang.hemiReplace.nii.gz ROIs/gonogo/SMC.hemiReplace.nii.gz ROIs/gonogo/A1.hemiReplace.nii.gz ROIs/gonogo/V1.hemiReplace.nii.gz ROIs/gonogo/MV.hemiReplace.nii.gz ROIs/gonogo/occLobe_erode20mm_excludeMV.hemiReplace.nii.gz ROIs/gonogo/occLobe_erode20mm_MV.hemiReplace.nii.gz) # you have to use hemiReplace or things will get overwritten weirdly

zStats=(0 11-LOO 10-LOO 9-LOO 15-LOO) # this is also dependent on design matrix. check for changes
# 22 = FG + IG + NG > Rest
# 11 = FG + IG > NG
# 10 = NG > FG
#  9 = NG > IG
# 15 = IG > FG

# note that a zStat = 0 means that you take the full ROI, not the top X percent or top X vertices
# if you want to do a leave one out analysis, zStat must have phrase "-LOO"
subs=(GNGC_S_01 GNGC_S_02 GNGC_S_04 GNGC_S_05 GNGC_S_06 GNGC_S_07 GNGC_S_08 GNGC_S_09 GNGC_S_10 GNGC_S_11 GNGC_S_12 GNGC_S_13 GNGC_S_14 GNGC_S_15 GNGC_S_16 GNGC_S_17 GNGC_S_18 GNGC_S_19 GNGC_S_20 GNGC_S_21 GNGC_S_22 GNGC_S_23 GNGC_S_24 GNGC_S_27 GNGC_CB_02 GNGC_CB_03 GNGC_CB_04 GNGC_CB_05 GNGC_CB_06 GNGC_CB_07 GNGC_CB_08 GNGC_CB_09 GNGC_CB_10 GNGC_CB_11 GNGC_CB_12 GNGC_CB_13 GNGC_CB_14 GNGC_CB_15 GNGC_CB_16 GNGC_CB_17 GNGC_CB_18 GNGC_CB_19 GNGC_CB_20 GNGC_CB_21 GNGC_CB_23 GNGC_CB_24 GNGC_CB_25)

ROI_CSV=GroupResults/${mainDir}/${outName}
if [ -e "$ROI_CSV" ]; then
    rm -r $ROI_CSV
fi

for roi_file in ${rois[@]}; do
  
  for hemi in lh rh bl; do
    
    roi=${roi_file/hemiReplace/$hemi}
    
    wb_command -metric-convert -from-nifti $roi $GNGC/SurfAnat/32k_fs_LR/surf/lh.midthickness.surf.gii ${roi/nii.gz/gii};
    
    for zstat in ${zStats[@]}; do		
      
      for sub in ${subs[@]}; do	
        
        for run in `seq 1 3`; do # assumes there are 3 runs
	        
          CMD=	
	      
          roi_name=$(basename "$roi")
	        roi_name=${roi_name/.gii/}
	        roi_name=${roi_name/.nii.gz/}
	  
          #only if this ROI exists; some hemis don't
          if [[ -f $roi ]]; then
	          
            subROI=$sub/$subROI_dir/${roi_name}/con${zstat}/${sub}.run0${run}
	          rm -rf $subROI
	          mkdir -p $subROI
	        
            if [[ ${zstat} != "0" ]]; then # a z-stat of 0 means you take the full ROI
	          
              if [[ ${roi} == *".bl."* ]]; then
		
                if [[ ${zstat} == *"-LOO"* ]]; then
		  
                  CMD+="wb_command -metric-convert -to-nifti $sub/$secondlevelLOO/gonogo-0${run}.lh.ffx/zstat${zstat/-LOO/}.func.gii $subROI/zstat.lh.nii.gz; " 	
                  CMD+="wb_command -metric-convert -to-nifti $sub/$secondlevelLOO/gonogo-0${run}.rh.ffx/zstat${zstat/-LOO/}.func.gii $subROI/zstat.rh.nii.gz; "		
		
                else
		  
                  CMD+="wb_command -metric-convert -to-nifti $sub/$secondlevel/gonogo.lh.ffx/zstat${zstat}.func.gii $subROI/zstat.lh.nii.gz; " 	
                  CMD+="wb_command -metric-convert -to-nifti $sub/$secondlevel/gonogo.rh.ffx/zstat${zstat}.func.gii $subROI/zstat.rh.nii.gz; "		
		
                fi
		
                CMD+="fslmerge -y $subROI/zstat.bl.nii.gz $subROI/zstat.lh.nii.gz $subROI/zstat.rh.nii.gz; "
                subZstat=$subROI/zstat.bl.nii.gz
	            
              else
		
                if [[ ${zstat} == *"-LOO"* ]]; then
		      
                  CMD+="wb_command -metric-convert -to-nifti $sub/$secondlevelLOO/gonogo-0${run}.${hemi}.ffx/zstat${zstat/-LOO/}.func.gii $subROI/zstat.${hemi}.nii.gz; "
		            
                else
		  
                  CMD+="wb_command -metric-convert -to-nifti $sub/$secondlevel/gonogo.${hemi}.ffx/zstat${zstat}.func.gii $subROI/zstat.${hemi}.nii.gz; "
		            fi

		          subZstat=$subROI/zstat.${hemi}.nii.gz
	            
              fi
	          fi
	    
            if [[ ${zstat} != "0" ]]; then
              
              if [[ $is_percent == 0 ]]; then
	              
                CMD+="num_sspace_vertices=\`fslstats ${roi} -V\`; "  
                CMD+="num_sspace_vertices=\$(echo \${num_sspace_vertices} | awk '{print \$2}'); "
                CMD+="lower_percent=\`echo 100 - 100*${top_num}/\$num_sspace_vertices | bc -l\`; "		
	      
              else
                
                CMD+="lower_percent=\`echo 100 - ${top_num} | bc -l\`; "
              
              fi
	      
              CMD+="thres=\`fslstats $subZstat -k $roi -P \${lower_percent}\`; "	
              CMD+="fslmaths $subZstat -mas $roi -thr \$thres -abs -bin $subROI/shape.${hemi}.nii.gz; " # Don't forget to take absolute value or binarize will miss negative values
	          
            else
	      
              CMD+="cp $roi $subROI/shape.${hemi}.nii.gz; "
              CMD+="thres=N/A; "	
	          fi
          
          CMD+="numVertex=\`fslstats $subROI/shape.${hemi}.nii.gz -V\`; "  
          CMD+="numVertex=\$(echo \$numVertex | awk '{print \$2}'); "         
	    
          if [[ ${roi} == *".bl."* ]]; then
	      
            CMD+="fslsplit $subROI/shape.${hemi}.nii.gz $subROI/shape -y; "
            CMD+="wb_command -metric-convert -from-nifti ${subROI}/shape0000.nii.gz $GNGC/SurfAnat/32k_fs_LR/surf/lh.midthickness.surf.gii $subROI/shape.lh.gii; "
            CMD+="wb_command -metric-convert -from-nifti ${subROI}/shape0001.nii.gz $GNGC/SurfAnat/32k_fs_LR/surf/rh.midthickness.surf.gii $subROI/shape.rh.gii; "
            CMD+="rm -r ${subROI}/shape0000.nii.gz ${subROI}/shape0001.nii.gz; "
	        
          else
	        
            CMD+="wb_command -metric-convert -from-nifti ${subROI}/shape.${hemi}.nii.gz $GNGC/SurfAnat/32k_fs_LR/surf/${hemi}.midthickness.surf.gii $subROI/shape.${hemi}.gii; "
	        fi
	      fi
	  
        i=-1
	  
        CMD+="line=\"${roi_name},con${zstat},${sub},run0${run},\${numVertex},\${thres}\"; "
	  
        for copeStat in ${copeStats[@]}; do
	      
          i=$((i+1))
	        copeStatName=${conds[${i}]};
	        
          if [[ ${roi} == *".bl."* ]]; then
	          
            CMD+="wb_command -metric-convert -to-nifti $sub/$firstlevel/gonogo_0${run}.lh.glm/stats/cope${copeStat}.func.gii $subROI/cope${copeStat}.lh.nii.gz; " 	
            CMD+="wb_command -metric-convert -to-nifti $sub/$firstlevel/gonogo_0${run}.rh.glm/stats/cope${copeStat}.func.gii $subROI/cope${copeStat}.rh.nii.gz; "		
            CMD+="fslmerge -y $subROI/cope${copeStat}.bl.nii.gz $subROI/cope${copeStat}.lh.nii.gz $subROI/cope${copeStat}.rh.nii.gz; "
            subcopeStat=$subROI/cope${copeStat}.bl.nii.gz

	        else
	      
            CMD+="wb_command -metric-convert -to-nifti $sub/$firstlevel/gonogo_0${run}.$hemi.glm/stats/cope${copeStat}.func.gii $subROI/cope${copeStat}.$hemi.nii.gz; "
            subcopeStat=$subROI/cope${copeStat}.$hemi.nii.gz
	        fi
	    
          CMD+="beta=\`fslstats $subcopeStat -k $subROI/shape.${hemi}.nii.gz -M\`; "
          CMD+="line+=\",$copeStatName,\$beta\"; " 	
	      done
	  
        CMD+="echo \$line >> $ROI_CSV; "		
	      
        echo $CMD >> $jobfile
      done
    done
  done
done
done

echo "parallel -j 15 < $jobfile"

