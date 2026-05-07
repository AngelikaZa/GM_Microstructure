#!/bin/bash

basedir="/mnt/y/PROJECTS/GMmicrostructure/DATA/Longitudinal_VIPD/SESSION1"

cd ${basedir}
mapfile -t allsubs < /mnt/y/PROJECTS/GMmicrostructure/DATA/Batch.txt

template=/mnt/y/PROJECTS/GMmicrostructure/DATA/fsaverage/fsaverage_brain.nii.gz

for sub in ${allsubs[@]}; do
  subdir=$basedir/$sub
  cd $subdir
  
  #fwf_nii=AMICO/NODDI/fit_FWF.nii.gz
  fwf_nii=AMICO/NODDI/FWF_in_template.nii.gz
  #mask_nii=DWI_brain_resampled.nii.gz
  #fslmaths $fwf_nii -mul 1 -add 1 -mas $mask_nii AMICO/NODDI/FWF_ftissue.nii.gz
  fslmaths $fwf_nii -mul 1 -add 1 AMICO/NODDI/FWF_ftissue_in_template.nii.gz

  maps=("NDI" "ODI")
  for map in ${maps[@]}; do
    input_nii=AMICO/NODDI/fit_${map}.nii.gz
    output_nii=AMICO/NODDI/${map}_ftissue_in_template.nii.gz
    fslmaths AMICO/NODDI/FWF_ftissue_in_template.nii.gz -mul $input_nii $output_nii
  done
done
