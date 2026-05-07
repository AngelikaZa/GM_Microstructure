#!/bin/bash

basedir="/mnt/y/PROJECTS/GMmicrostructure/DATA/Longitudinal_VIPD/SESSION1"

cd ${basedir}
mapfile -t allsubs < /mnt/y/PROJECTS/GMmicrostructure/DATA/Batch.txt

template=/mnt/y/PROJECTS/GMmicrostructure/DATA/fsaverage/fsaverage_brain.nii.gz

for sub in ${allsubs[@]}; do
  subdir=$basedir/$sub
  cd $subdir
    
  maps=("FWF" "NDI" "ODI")
  t1="T1.nii.gz"
  b0="b0.nii.gz"
  reg_aladin -ref $template -flo $t1 -aff T1_to_template_aff.txt
  reg_f3d -ref $template -flo $t1 -aff T1_to_template_aff.txt -cpp T1_to_template.cpp.nii.gz
  reg_transform -invAff T1_to_DWI_aff.txt DWI_to_T1_aff.txt
  reg_transform -ref $template -ref2 $b0 -comp T1_to_template.cpp.nii.gz DWI_to_T1_aff.txt DWI_to_template_aff.nii

  for map in ${maps[@]}; do
    input_nii=AMICO/NODDI/fit_${map}.nii.gz
    output_nii=AMICO/NODDI/${map}_in_template.nii.gz
    reg_resample -ref $template -flo $input_nii -trans DWI_to_template_aff.nii -inter CUB -res $output_nii

  #   for hemi in L R; do
  #     surf=$basedir/fsaverage/${hemi}.midthickness.fsavg6.surf.gii
  #     white=$basedir/fsaverage/${hemi}.white.fsavg6.surf.gii
  #     pial=$basedir/fsaverage/${hemi}.pial.fsavg6.surf.gii
  #     output_fsavg6=AMICO/NODDI/$sub.${hemi}.${map}.fsavg6.gii
  #     output_fsLR=AMICO/NODDI/$sub.${hemi}.${map}.fsLR32.gii
  #     src_sph=$basedir/fsaverage/fsaverage6.${hemi}.sphere.41k_fsavg_${hemi}.surf.gii
  #     tgt_sph=$basedir/fsaverage/fs_LR-deformed_to-fsaverage.${hemi}.sphere.32k_fs_LR.surf.gii
  #     tgt_va=$basedir/fsaverage/fs_LR.${hemi}.midthickness_va_avg.32k_fs_LR.shape.gii
  #     fsavg_va=$basedir/fsaverage/${hemi}.fsavg6_va.shape.gii 
  #     wb_command -volume-to-surface-mapping NODDI_in_fsavg6.nii.gz $surf $output_fsavg6 -ribbon-constrained $white $pial -trilinear
  #     wb_command -metric-resample ${output_fsavg6} ${src_sph} ${tgt_sph} ADAP_BARY_AREA ${output_fsLR} -area-metrics ${fsavg_va} ${tgt_va}
  # done
  done
done
