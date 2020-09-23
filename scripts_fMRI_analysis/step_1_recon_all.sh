subs=(GNGC_S_01 GNGC_S_02)

job=./jobs/run_recon.txt
rm -r $job

for SUBJID in ${subs[@]}; do
  echo "recon-all -all -subjid $SUBJID" >> $job
done
