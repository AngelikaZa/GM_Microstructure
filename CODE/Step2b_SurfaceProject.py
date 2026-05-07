import subprocess
from pathlib import Path
import argparse
import pandas as pd
import sys

## fs_LR files downloaded from: https://github.com/Washington-University/HCPpipelines/tree/master/global/templates/standard_mesh_atlases 

parser = argparse.ArgumentParser()
parser.add_argument("-subs", type=str, help="path to list of subjects")
parser.add_argument("-analysis", type=str, help="base, or s1 or s2")
args = parser.parse_args()
participant_list = args.subs
analysis = args.analysis

# Define paths
root = Path("Y:/PROJECTS/GMmicrostructure/DATA")
if analysis == "s1":
    basedir = root / "Longitudinal_VIPD/SESSION1"
elif analysis == "s2":
    basedir = root / "Longitudinal_VIPD/SESSION2"
else:
    basedir = root

fsavg_dir = root / "fsaverage"
template = fsavg_dir / "fsaverage_brain.nii.gz"

maps = ["FWF", "NDI", "ODI"]
hemis = ["L", "R"]

participants = pd.read_csv(participant_list, header=None, sep="\t", engine="python")[0].astype(str).str.strip()

for participant_id in participants:
    subdir = basedir / participant_id
    # Registrations
    t1 = subdir / "T1.nii.gz"
    b0 = subdir / "b0.nii.gz"
    # out_warp = subdir / "sub_to_template_warp.nii.gz"
    # subprocess.run([
    #     "reg_aladin", "-ref", str(template), "-flo", str(t1),
    #     "-aff", str(subdir/"T1_to_template_aff.txt")], check=True)
    # subprocess.run([
    #     "reg_f3d", "-ref", str(template), "-flo", str(t1),
    #     "-aff", str(subdir/"T1_to_template_aff.txt"),
    #     "-cpp", str(subdir/"T1_to_template.cpp.nii.gz")], check=True)
    # subprocess.run([
    #     "reg_trasnform", "-invAff", str(subdir/"T1_to_DWI_aff.txt"), str(subdir/"DWI_to_T1_aff.txt")], check=True)
    # subprocess.run([
    #     "reg_trasnform", "-ref", str(template), "-ref2", str(b0), "-comp", str(subdir/T1_to_template.cpp.nii.gz),
    #     str(subdir/"DWI_to_T1_aff.txt"), str(subdir/"DWI_to_template_aff.txt")])
         
    for map_name in maps:
        # # Apply transforms to each map to create a map in template volume
        # input_nii = subdir / f"AMICO/NODDI/fit_{map_name}.nii.gz"
        output_nii = subdir / f"AMICO/NODDI/{map_name}_in_template.nii.gz"
        # subprocess.run([
        # "reg_resample", "-ref", str(t1),  "-flo", str(input_nii),
        # "-trans", str(subdir/"DWI_to_template_aff.txt"), "-inter", "CUB",
        # "-res", str(output_nii)], check=True)

        for hemi in hemis:
            surf = fsavg_dir / f"{hemi}.midthicknesss.fsavg6.surf.gii"
            white = fsavg_dir / f"{hemi}.white.fsavg6.surf.gii"
            pial  = fsavg_dir / f"{hemi}.pial.fsavg6.surf.gii"
            output_fsavg6 = subdir / f"AMICO/NODDI/{participant_id}.{hemi}.{map_name}.fsavg6.func.gii"
            output_fsLR = subdir / f"AMICO/NODDI/{participant_id}.{hemi}.{map_name}.fsLR32.func.gii"
            src_sph = fsavg_dir / f"fsaverage6_std_sphere.{hemi}.41k_fsavg_{hemi}.surf.gii"
            tgt_sph = fsavg_dir / f"fs_LR-deformed_to-fsaverage.{hemi}.sphere.32k_fs_LR.surf.gii"
            tgt_va = fsavg_dir / f"fs_LR.{hemi}.midthickness_va_avg.32k_fs_LR.shape.gii"
            fsavg_va = fsavg_dir /f"{hemi}.fsavg6_va.shape.gii" 
            subprocess.run([
                "wb_command", "-volume-to-surface-mapping",
                str(output_nii), str(surf), str(output_fsavg6),
                "-ribbon-constrained", str(white), str(pial)], check=True)

            subprocess.run([
                "wb_command", "-metric-resample", str(output_fsavg6), 
                str(src_sph), str(tgt_sph), "ADAP_BARY_AREA", 
                str(output_fsLR), "-area-metrics", str(fsavg_va), str(tgt_va)], check=True)