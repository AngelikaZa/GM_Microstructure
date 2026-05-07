#!/bin/bash

basedir="/mnt/y/PROJECTS/GMmicrostructure/DATA/"

cd ${basedir}
mapfile -t allsubs < /mnt/y/PROJECTS/GMmicrostructure/DATA/Batch.txt

tian_atlas=/mnt/y/PROJECTS/GMmicrostructure/DATA/Tian_Subcortex_S2_3T_1mm.nii.gz
output=$basedir/ALL_SUBJECTS_NODDI_TIAN.csv
echo "SUBJECT,ROI,NDI_MEAN,ODI_MEAN,FWF_MEAN,NDI_TWMEAN,ODI_TWMEAN" > ${output}

for sub in ${allsubs[@]}; do
	subdir=$basedir/$sub
	cd $subdir
	ndi=AMICO/NODDI/NDI_ftissue.nii.gz
	odi=AMICO/NODDI/ODI_ftissue.nii.gz
	fwf=AMICO/NODDI/FWF_ftissue.nii.gz
	# transforms
	t1_to_dwi=$subdir/T1_to_DWI_aff.txt
	mni_to_t1=$subdir/MNI_to_T1_aff.txt
	# Output files
	tian_dwi=$subdir/Tian_32_inDWI.nii.gz
	out1="NODDI_TIAN_ROIs.csv"
	out2="TWM_NODDI_TIAN_ROIs.csv"
	echo "ROI, NDI_MEAN, ODI_MEAN, FWF_MEAN" > ${out1}

    # Register Tian to each participant's DWI
    reg_resample -ref $subdir/b0.nii.gz -flo $tian_atlas -trans $mni_to_t1 -res $subdir/Tian_inT1.nii.gz -inter 0
    reg_resample -ref $subdir/b0.nii.gz -flo $subdir/Tian_inT1.nii.gz -trans $t1_to_dwi -res $tian_dwi -inter 0

	# Loop through 32 ROIs
	for roi in {1..32}; do
		mask=$(mktemp)
		fslmaths ${atlas} -thr ${roi} -uthr ${roi} -bin ${mask}
		ndi_mean=$(fslstats ${ndi} -k ${mask} -m)
		odi_mean=$(fslstats ${odi} -k ${mask} -m)
		fwf_mean=$(fslstats ${fwf} -k ${mask} -m)
		echo "${roi}, ${ndi_mean}, ${odi_mean}, ${fwf_mean}" >> ${out1}
		rm -f ${mask}
	done

	# Tissue-weighted means
	echo "ROI, NDI_TWMEAN, ODI_TWMEAN, FWF_MEAN" > ${out2}
	tail -n +2 ${out1} | while IFS=, read -r roi ndi_mean odi_mean fwf_mean; do
	    ndi_twm=$(bc -l <<< "scale=10; ${ndi_mean}/${fwf_mean}")
	    odi_twm=$(bc -l <<< "scale=10; ${odi_mean}/${fwf_mean}")
	    echo "${roi}, ${ndi_twm}, ${odi_twm}, ${fwf_mean}" >> ${out2}
	done
# Collate for all participants
    in_csv="${subj_dir}/NODDI_TIAN_ROIs.csv"
    if [[ -f "${in_csv}" ]]; then
        echo "Adding ${subj}..."
        tail -n +2 "${in_csv}" | awk -v s="${subj}" -F, '{print s","$0}' >> ${output}
    else
        echo "Warning: ${in_csv} not found, skipping ${subj}"
    fi
done