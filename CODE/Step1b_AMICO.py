import os
from os.path import split, join
import argparse
import amico
import pandas as pd
from nilearn.image import new_img_like, resample_img
import nibabel as nib

parser=argparse.ArgumentParser()
parser.add_argument("-subs", type=str, help="path to list of subjects")
parser.add_argument("-analysis", type=str, help="base, or s1 or s2")
args=parser.parse_args()
participant_list=args.subs
analysis=args.analysis


amico.setup()
ae = amico.Evaluation()
amico.util.fsl2scheme('NODDI_protocol.bval', 'NODDI_protocol.bvec')

participants = pd.read_csv(participant_list, header=None, delimiter="/t", engine="python")
for participant_id in participants[0]:
	if analysis == "s1":
		in_dir=os.path.join("Y:\PROJECTS\GMmicrostructure\DATA\Longitudinal_VIPD\SESSION1", participant_id)
	elif analysis == "s2":
		in_dir=os.path.join("Y:\PROJECTS\GMmicrostructure\DATA\Longitudinal_VIPD\SESSION2", participant_id)
	elif analysis == "base":
		in_dir=os.path.join("Y:\PROJECTS\GMmicrostructure\DATA", participant_id)
	os.chdir(in_dir)
	noddi_img = nib.load("noddi.nii.gz")
	dwi = nib.load("DWI_brain.nii.gz")
	mask = resample_img(dwi, target_affine=noddi_img.affine, target_shape=noddi_img.shape[:3], interpolation='nearest', force_resample=True, copy_header=True)	
	nib.save(mask, "DWI_brain_resampled.nii.gz")
	ae.load_data("noddi.nii.gz",'Y:\PROJECTS/GMmicrostructure/ANALYSIS/NODDI_protocol.scheme', mask_filename='DWI_brain_resampled.nii.gz', b0_thr=0)
	ae.set_model('NODDI')
	ae.model.dPar = 1.1e-3      # optimal for grey matter
	ae.generate_kernels(regenerate=True)
	ae.load_kernels()
	ae.fit()
	ae.save_results()
