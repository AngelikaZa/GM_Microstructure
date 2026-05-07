#!/bin/bash
export SUBJECTS_DIR=/mnt/y/PROJECTS/GMmicrostructure/DATA

basedir="/mnt/y/PROJECTS/GMmicrostructure/DATA"

cd ${basedir}
mapfile -t allsubs < /mnt/y/PROJECTS/GMmicrostructure/DATA/Batch_N.txt

fs_dir="/mnt/z/fs_long"
#fs_dir="/mnt/y/home_study_2017_data/fs_long_S3"

HEMIS=("lh" "rh")
for sub in ${allsubs[@]}; do
  # new_name=${sub/VIPD_/sub-} ## for MMPD only
  echo $sub
  subdir=$basedir/$sub
  cd $subdir
  mkdir surf
  # cp $fs_dir/$sub/ses-01/freesurfer/surf/*.thickness.fsaverage.mgh $subdir ## for MMPD only
  cp ${fs_dir}/S3_${sub}.long.base_${sub}/surf/*.thickness.fsaverage.mgh $subdir/surf/
  
  for HEMI in "${HEMIS[@]}"; do
    mri_convert $subdir/surf/$HEMI.thickness.fsaverage.mgh $subdir/surf/$HEMI.thickness.fsavg6.func.gii
  done
done
