basedir="/mnt/y/PROJECTS/GMmicrostructure/DATA"

#basedir="/mnt/y/PROJECTS/GMmicrostructure/DATA/Longitudinal_VIPD/SESSION2"
mapfile -t allsubs < ../DATA/Batch.txt
cd ${basedir}
#allsubs=("VIPD_007")
for sub in "${allsubs[@]}"; do
    subdir=$basedir/$sub
    cd $subdir
    echo $sub
    # Create T1 segmentations and mask
    mri_synthstrip -i T1.nii.gz -o T1_brain_masked.nii.gz -m T1_brain.nii.gz
    fast -n 3 -o T1_seg T1.nii.gz
    fslmaths T1_seg_pve_1.nii.gz -mas T1_brain.nii.gz -thr 0.5 -bin T1_GM.nii.gz

    # Coregister to the DWI
    reg_aladin -ref b0.nii.gz -flo T1.nii.gz -res T1_in_DWIspace.nii.gz -aff T1_to_DWI_aff.txt
    reg_resample -ref b0.nii.gz -flo T1_brain.nii.gz -trans T1_to_DWI_aff.txt -res DWI_brain.nii.gz -inter 0
    reg_resample -ref b0.nii.gz -flo T1_GM.nii.gz -trans T1_to_DWI_aff.txt -res GM_mask.nii.gz -inter 0

    # # Shaefer parcellation to T1 
    reg_aladin -ref T1.nii.gz -flo $basedir/MNI152_T1_1mm.nii.gz -res MNI152_in_T1space.nii.gz -aff MNI_to_T1_aff.txt
    reg_resample -ref T1.nii.gz -flo $basedir/Schaefer2018_232Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -trans MNI_to_T1_aff.txt -res Schaefer232_T1space.nii.gz -aff MNI_to_T1_aff.txt -inter 0
    reg_resample -ref b0.nii.gz -flo Schaefer232_T1space.nii.gz -res Schaefer232_DWIspace.nii.gz -trans T1_to_DWI_aff.txt -inter 0

done
